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
ENV SMARTPEAK_DEPENDENCIES_VERSION master

# OpenMS versions
ENV OPENMS_VERSION develop
ENV OPENMS_REPOSITORY https://github.com/dmccloskey/OpenMS.git

# Installation of debian-deps:latest #[and curl from debian-curl:latest]
# procps is very common in build systems, and is a reasonably small package
RUN apk update && \
    apk add --no-cache \
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
    boost-unit_test_framework \

    # Install SmartPeak and OpenMS dependencies
    sqlite-dev \
    # coinor-libcoinutils-dev \

    # Install OpenMS dependencies (Boost libraries)
    boost-date_time \
    boost-iostreams \
    boost-regex \
    boost-math \
    boost-random \

    # Install OpenMS dependencies
    libzip-dev \
    bzip2-dev \
    zlib-dev \

    # Install OpenMS dependencies (QT5) 
    # mesa-dev \
    mesa-gl \
    qt5-qtbase-dev \
    # qt5-qtwebengine-dev \ # in testing (may not be needed anyway)
    qt5-qtsvg-dev && \   

    # Clean up
    # apk del .build-dependencies && \

    # Install OpenMS dependencies from source (COIN-OR)
    # cd /usr/local/ && \
    # wget https://www.coin-or.org/download/source/Cbc/Cbc-2.9.9.tgz && \
    # tar -xzvf Cbc-2.9.9.tgz && \
    # cd Cbc-2.9.9 && \
    # ./configure && \
    # make -j8 && \
    # cd /usr/local/ && \
    # wget https://www.coin-or.org/download/source/Cgl/Cgl-0.59.10.tgz && \
    # tar -xzvf Cgl-0.59.10.tgz && \
    # cd Cgl-0.59.10 && \
    # ./configure && \
    # make -j8 && \
    # cd /usr/local/ && \
    # wget https://www.coin-or.org/download/source/Clp/Clp-1.16.11.tgz && \
    # tar -xzvf Clp-1.16.11.tgz && \
    # cd Clp-1.16.11 && \
    # ./configure && \
    # make -j8 && \
    cd /usr/local/ && \
    wget https://www.coin-or.org/download/source/CoinMP/CoinMP-1.8.3.tgz && \
    tar -xzvf CoinMP-1.8.3.tgz && \
    cd CoinMP-1.8.3 && \
    ./configure && \
    make -j8 && \

    # Install OpenMS dependencies from source (libsvm)
    cd /usr/local/ && \
    wget -O libsvm-v322.tar.gz https://github.com/cjlin1/libsvm/archive/v322.tar.gz && \
    tar -xzvf libsvm-v322.tar.gz && \
    cd libsvm-322 && \
    # ./configure && \
    make -j8 all lib && \

    # Install OpenMS dependencies from source (eigen)
    cd /usr/local/ && \
    wget -O eigen-3.3.4.tar.bz2 http://bitbucket.org/eigen/eigen/get/3.3.4.tar.bz2 && \
    mkdir eigen-3.3.4 && \
    tar --strip-components=1 -xvjf eigen-3.3.4.tar.bz2 -C eigen-3.3.4 && \
    cd eigen-3.3.4 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j8 && \

    # Install OpenMS dependencies from source (xerces-c)
    cd /usr/local/ && \
    wget http://www.apache.org/dist/xerces/c/3/sources/xerces-c-3.2.1.tar.gz && \
    tar -xvf xerces-c-3.2.1.tar.gz && \
    cd xerces-c-3.2.1 && \
    ./configure && \
    make -j8 && \

    # Install OpenMS dependencies from source (glpk)
    cd /usr/local/ && \
    wget ftp://ftp.gnu.org/gnu/glpk/glpk-4.55.tar.gz && \
    tar -xzvf glpk-4.55.tar.gz && \
    cd glpk-4.55 && \
    ./configure && \
    make -j8 && \

    # Clone the SmartPeak/dependencies repository
    cd /usr/local/  && \
    git clone https://github.com/dmccloskey/smartPeak_dependencies.git && \
    cd /usr/local/smartPeak_dependencies && \
    git checkout ${SMARTPEAK_DEPENDENCIES_VERSION} && \
    mkdir /usr/local/contrib-build/  && \
    # Build SmartPeak/dependencies
    cd /usr/local/contrib-build/  && \
    cmake -DBUILD_TYPE=SEQAN ../smartPeak_dependencies && rm -rf archives src && \
    cmake -DBUILD_TYPE=WILDMAGIC ../smartPeak_dependencies && rm -rf archives src
    # cmake -DBUILD_TYPE=EIGEN ../smartPeak_dependencies && rm -rf archives src && \
    # cmake -DBUILD_TYPE=COINOR ../smartPeak_dependencies && rm -rf archives src && \
    # && \
    # cmake -DBUILD_TYPE=SQLITE ../smartPeak_dependencies && rm -rf archives src && \

    # clone the OpenMS repository
RUN    cd /usr/local/  && \
    git clone ${OPENMS_REPOSITORY} && \
    cd /usr/local/OpenMS/ && \
    git checkout ${OPENMS_VERSION} && \
    cd /usr/local/ && \
    mkdir openms-build && \
    cd /usr/local/openms-build/ && \
    # define QT environment
    # export QT_BASE_DIR=/opt/qt57 && \
    # export QTDIR=$QT_BASE_DIR\n\
    # export PATH=$QT_BASE_DIR/bin:$PATH\n\
    # export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH && \
    # export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH && \
    cmake -DWITH_GUI=OFF -DPYOPENMS=OFF -DPYTHON_EXECUTABLE:FILEPATH=/usr/local/bin/python3 -DOPENMS_CONRIB_LIBS='/usr/local/;/usr/' -DCMAKE_PREFIX_PATH='/usr/local/contrib-build/;/usr/local/smartPeak_dependencies/;/usr/;/usr/local/' -DBOOST_USE_STATIC=OFF -DHAS_XSERVER=Off ../OpenMS && \
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