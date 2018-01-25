# Dockerfile to build SmartPeak images

# Add python3_scientific
FROM alpine:latest

# File Author / Maintainer
LABEL maintainer Douglas McCloskey <dmccloskey87@gmail.com>

# Switch to root for install
USER root

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# SmartPeak versions
ENV SMARTPEAK_DEPENDENCIES_VERSION master

# Installation of debian-deps:latest #[and curl from debian-curl:latest]
# procps is very common in build systems, and is a reasonably small package
RUN apt-get update && apt-get upgrade -y \
	&& apt-get install -y \
		curl \
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion \
		--no-install-recommends\
		procps \
	&& rm -rf /var/lib/apt/lists/*
	
# Install lapack and blas
RUN apt-get update && apt-get upgrade -y \
	&& apt-get install -y \
		libatlas-base-dev \
		#libjpeg62-dev \
		libfreetype6 \
		libpng12-dev \
		libagg-dev \
		pkg-config \
		gfortran \
		\
		libopenblas-dev \
		liblapack-dev \
		libzmq-dev \	
		\
		libreadline-gplv2-dev \
		libncursesw5-dev \
		libssl-dev \
		libsqlite3-dev \
		tk-dev \
		libgdbm-dev \
		libc6-dev \
		libbz2-dev \
		libhdf5-dev \
		libpq-dev \
		#libcupti-dev \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# Install SmartPeak dependencies
RUN apt-get -y update && \
    apt-get install -y \
    cmake \
    g++ \
    autoconf \
    patch \
    libtool \
    make \
    git \
    software-properties-common \
    python-software-properties \
    libboost-all-dev \
    libglpk-dev \
    libzip-dev \
    zlib1g-dev \
	--no-install-recommends \
    libbz2-dev && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # install cmake from source
    cd /usr/local/ && \
    wget http://www.cmake.org/files/v3.8/cmake-3.8.2.tar.gz && \
    tar xf cmake-3.8.2.tar.gz && \
    cd cmake-3.8.2 && \
    ./configure && \
    make

# add cmake to the path
ENV PATH /usr/local/cmake-3.8.2/bin:$PATH

# Clone the SmartPeak/dependencies repository
RUN cd /usr/local/  && \
    git clone https://github.com/dmccloskey/smartPeak_dependencies.git && \
    cd /usr/local/dependencies && \
    git checkout ${SMARTPEAK_DEPENDENCIES_VERSION} && \
    mkdir /usr/local/dependencies-build/  && \
    # Build SmartPeak/dependencies
    cd /usr/local/dependencies-build/  && \
    cmake -DBUILD_TYPE=WILDMAGIC ../dependencies && \
    cmake -DBUILD_TYPE=COINOR ../dependencies && \
    cmake -DBUILD_TYPE=ZLIB ../dependencies && \
    cmake -DBUILD_TYPE=BZIP2 ../dependencies && \
    cmake -DBUILD_TYPE=GLPK ../dependencies && \
    cmake -DBUILD_TYPE=SQLITE ../dependencies && \
    cmake -DBUILD_TYPE=BOOST ../dependencies
	
# create a user
ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
    && chmod -R u+rwx $HOME \
    && chown -R user:user $HOME

# switch back to user
WORKDIR $HOME
USER user