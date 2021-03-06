# Dockerfile to build SmartPeak images

# Add python3_scientific
FROM alpine:latest

# File Author / Maintainer
LABEL maintainer Douglas McCloskey <dmccloskey87@gmail.com>

# Switch to root for install
USER root

# ## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
# RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
# 	&& locale-gen en_US.utf8 \
# 	&& /usr/sbin/update-locale LANG=en_US.UTF-8

# ENV LC_ALL en_US.UTF-8
# ENV LANG en_US.UTF-8

# SmartPeak versions
ENV SMARTPEAK_DEPENDENCIES_VERSION feature/openmsDep

# OpenMS versions
ENV OPENMS_VERSION develop
ENV OPENMS_REPOSITORY https://github.com/dmccloskey/OpenMS.git

# Installation of debian-deps:latest #[and curl from debian-curl:latest]
# procps is very common in build systems, and is a reasonably small package
RUN apk add --no-cache \
    # --virtual .build-dependencies \
    bash \
    wget \
    bzr \
    git \
    mercurial \
    openssh-client \
    subversion \
    libstdc++ \
    procps \

    # Install lapack and blas
    gfortran \
    # openblas-dev \ # either openblas or lapack
    lapack-dev \
    tk-dev \
    gdbm-dev \

    # Install SmartPeak dependencies
    cmake \
    g++ \
    autoconf \
    automake \
    patch \
    libtool \
    make \
    git \
    libboost-test1.54-dev \

    # Install OpenMS dependencies
    libsvm-dev \
    libglpk-dev \
    libzip-dev \
    libxerces-c-dev \
    zlib1g-dev \
    libbz2-dev \

    # Install Boost libraries
    libboost-date-time1.54-dev \
    libboost-iostreams1.54-dev \
    libboost-regex1.54-dev \
    libboost-math1.54-dev \
    libboost-random1.54-dev \

    # Install QT5 
    software-properties-common \
    python-software-properties \
    libgl1-mesa-dev && \
    add-apt-repository ppa:beineri/opt-qt571-trusty && \
    apt-get -y update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    qt57base \
    qt57webengine \
    qt57svg && \    

    # Clean up
    # apk del .build-dependencies && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    
    # install cmake from source
    cd /usr/local/ && \
    wget http://www.cmake.org/files/v3.8/cmake-3.8.2.tar.gz && \
    tar xf cmake-3.8.2.tar.gz && \
    cd cmake-3.8.2 && \
    ./configure && \
    make -j8

# add cmake to the path
ENV PATH /usr/local/cmake-3.8.2/bin:$PATH

# Clone the SmartPeak/dependencies repository
RUN cd /usr/local/  && \
    git clone https://github.com/dmccloskey/smartPeak_dependencies.git && \
    cd /usr/local/smartPeak_dependencies && \
    git checkout ${SMARTPEAK_DEPENDENCIES_VERSION} && \
    mkdir /usr/local/contrib-build/  && \
    # Build SmartPeak/dependencies
    cd /usr/local/contrib-build/  && \
    cmake -DBUILD_TYPE=SEQAN ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=WILDMAGIC ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=EIGEN ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=COINOR ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=SQLITE ../contrib && rm -rf archives src && \
    # clone the OpenMS repository
    cd /usr/local/  && \
    git clone ${OPENMS_REPOSITORY} && \
    cd /usr/local/OpenMS/ && \
    git checkout ${OPENMS_VERSION} && \
    cd /usr/local/ && \
    mkdir openms-build && \
    cd /usr/local/openms-build/ && \
    # define QT environment
    QT_ENV=$(find /opt -name 'qt*-env.sh') && \
    # source ${QT_ENV} && cmake -DPYOPENMS=OFF -DPYTHON_EXECUTABLE:FILEPATH=/usr/local/bin/python3 -DCMAKE_PREFIX_PATH="/usr/local/contrib-build/;/usr/local/contrib/;/usr/;/usr/local" -DBOOST_USE_STATIC=OFF -DHAS_XSERVER=Off ../OpenMS && \
    /bin/bash -c "source ${QT_ENV} && cmake -DWITH_GUI=OFF -DPYOPENMS=ON -DPYTHON_EXECUTABLE:FILEPATH=/usr/local/bin/python3 -DCMAKE_PREFIX_PATH='/usr/local/contrib-build/;/usr/local/contrib/;/usr/;/usr/local' -DBOOST_USE_STATIC=OFF -DHAS_XSERVER=Off ../OpenMS" && \
    make -j8

# add openms to the list of libraries
ENV LD_LIBRARY_PATH /usr/local/openms-build/lib/:$LD_LIBRARY_PATH

# add openms to the PATH
ENV PATH /usr/local/openms-build/bin/:$PATH
	
# create a user
ENV HOME /home/user
RUN mkdir /home/user \
    && adduser -D -h $HOME user \
    && chmod -R u+rwx $HOME \
    && chown -R user:user $HOME

# switch back to user
WORKDIR $HOME
USER user
