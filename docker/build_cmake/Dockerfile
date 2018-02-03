# Dockerfile to build SmartPeak images

# Add python3_scientific
FROM alpine:latest

# File Author / Maintainer
LABEL maintainer Douglas McCloskey <dmccloskey87@gmail.com>

# Switch to root for install
USER root

# SmartPeak versions
ENV SMARTPEAK_DEPENDENCIES_VERSION feature/openmsDep

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
    git && \
    # apk del .build-dependencies && \
    # install cmake from source
    cd /usr/local/ && \
    wget http://www.cmake.org/files/v3.8/cmake-3.8.2.tar.gz && \
    tar xf cmake-3.8.2.tar.gz && \
    cd cmake-3.8.2 && \
    ./configure && \
    make -j8
	
# create a user
ENV HOME /home/user
RUN mkdir /home/user \
    && adduser -D -h $HOME user \
    && chmod -R u+rwx $HOME \
    && chown -R user:user $HOME

# switch back to user
WORKDIR $HOME
USER user
