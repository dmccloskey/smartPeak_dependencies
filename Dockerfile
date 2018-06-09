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
# ENV OPENMS_VERSION develop
Env OPENMS_VERSION fix/BoostCMake
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

    # Install CUDA dependencies
    # linux-firmware-nvidia \
    xf86-video-nv \ 
    flex-dev \
    bison \
    gdb \

    # Install SmartPeak and OpenMS dependencies
    sqlite-dev \
    # coinor-libcoinutils-dev \

    # Install OpenMS dependencies
    libzip-dev \
    bzip2-dev \
    zlib-dev \

    # # [NOTE: required for C++ 17]
    # # Install gcc dependencies (c++ 17)
    # gmp-dev \
    # mpfr-dev \ 
    # mpc1-dev \

    # Install OpenMS dependencies (QT5) 
    # mesa-dev \
    mesa-gl \
    qt5-qtbase-dev \
    # qt5-qtwebengine-dev \ # [NOTE: in testing (may not be needed anyway)]
    qt5-qtsvg-dev \   

    # [NOTE: not needed]
    # Install OpenMS dependencies from older repositories (Boost libraries)
    # && \
    # echo 'http://dl-2.alpinelinux.org/alpine/v2.7/main' >> /etc/apk/repositories && \
    # apk add --no-cache \
    # boost-date_time=1.54.0-r1 \
    # boost-iostreams=1.54.0-r1 \
    # boost-regex=1.54.0-r1 \
    # boost-math=1.54.0-r1 \    
    # boost-random=1.54.0-r1 && \ 

    # Install OpenMS dependencies (Boost libraries)
    boost-date_time \
    boost-iostreams \
    boost-regex \
    boost-math \    
    boost-random && \ 

    # Clean up
    # apk del .build-dependencies && \

    # # [NOTE: required for C++ 17]
    # # Install gcc 8.1.0 from source (c++ 17)
    # cd /usr/local/ && \
    # wget http://www.netgull.com/gcc/releases/gcc-8.1.0/gcc-8.1.0.tar.gz && \
    # tar -xf gcc-8.1.0.tar.gz && \
    # cd gcc-8.1.0 && \
    # # ./contrib/download_prerequisites && \
    # mkdir build && \
    # cd build && \
    # ../configure --prefix=/usr/local/gcc-8.1.0 --enable-languages=c,c++ --disable-multilib --enable-shared --enable-threads=posix --enable-__cxa_atexit --enable-clocale=gnu && \
    # make -j8 && \
    # make install && \

    # Install CUDA toolkit from source
    cd /usr/local/ && \
    # wget https://developer.download.nvidia.com/compute/cuda/opensource/9.1.128/cuda-gdb-9.1.128.src.tar.gz && \
    # tar -xzvf cuda-gdb-9.1.128.src.tar.gz && \
    # cd cuda-gdb-9.1.128 && \
    # ./configure && \
    # cmake && \
    # make -j8 && \
    wget https://developer.nvidia.com/compute/cuda/9.2/Prod/local_installers/cuda_9.2.88_396.26_linux && \
    chmod +x cuda_9.2.88_396.26_linux && \
    ./cuda_9.2.88_396.26_linux --tar mxvf && \
    wget https://developer.nvidia.com/compute/cuda/9.2/Prod/patches/1/cuda_9.2.88.1_linux && \
    chmod +x cuda_9.2.88.1_linux && \
    ./cuda_9.2.88.1_linux --tar mxvf && \

    # Install OpenMS dependencies from source (COIN-OR)
    # [NOTE: testing the use of individual packages instead of CoinMP]
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
    
    # # install cmake from source (may be needed for cuda and c++17)
    # cd /usr/local/ && \
    # wget http://www.cmake.org/files/v3.8/cmake-3.8.2.tar.gz && \
    # tar xf cmake-3.8.2.tar.gz && \
    # cd cmake-3.8.2 && \
    # ./configure && \
    # make -j8 && \

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

# # add cmake to the path
# ENV PATH /usr/local/cmake-3.8.2/bin:$PATH

# add cuda to the path
ENV PATH=/usr/local/cuda/bin:$PATH LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
# ENV LD_LIBRARY_PATH /usr/local/cuda-gdb-9.1.128/lib64:$LD_LIBRARY_PATH
# ENV PATH /usr/local/cuda-gdb-9.1.128/bin:$PATH

# update the environmental variables
ENV PKG_CONFIG_PATH /usr/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH /usr/local/CoinMP-1.8.3/lib:/usr/local/libsvm-322/lib:/usr/local/eigen-3.3.4/lib:/usr/local/xerces-c-3.2.1/lib:/usr/local/glpk-4.55/lib:/usr/lib:$LD_LIBRARY_PATH
ENV PATH /usr/local/CoinMP-1.8.3/bin:/usr/local/libsvm-322/bin:/usr/local/eigen-3.3.4/bin:/usr/local/xerces-c-3.2.1/bin:/usr/local/glpk-4.55/bin:/usr/bin:$PATH

# # [TODO: fix findBOOST in OpenMS installation]
# # clone and install the OpenMS repository
# RUN    cd /usr/local/  && \
#     git clone ${OPENMS_REPOSITORY} && \
#     cd /usr/local/OpenMS/ && \
#     git checkout ${OPENMS_VERSION} && \
#     cd /usr/local/ && \
#     mkdir openms-build && \
#     cd /usr/local/openms-build/ && \
#     # define QT environment
#     # export QT_BASE_DIR=/opt/qt57 && \
#     # export QTDIR=$QT_BASE_DIR\n\
#     # export PATH=$QT_BASE_DIR/bin:$PATH\n\
#     # export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH && \
#     # export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH && \
#     cmake -DWITH_GUI=OFF -DPYOPENMS=OFF -DPYTHON_EXECUTABLE:FILEPATH=/usr/local/bin/python3 \
#         -DCMAKE_PREFIX_PATH='/usr/local/contrib-build;/usr/local/smartPeak_dependencies;/usr;/usr/local;/usr/lib;/usr/lib/cmake' \
#         -DBOOST_USE_STATIC=OFF \
#         # -DBOOST_USE_DYNAMIC=ON \
#         -DHAS_XSERVER=Off \
#         ../OpenMS && \
#     make -j8

# # [TODO: fix findBOOST in OpenMS installation]
# # add openms to the list of libraries
# ENV LD_LIBRARY_PATH /usr/local/openms-build/lib/:$LD_LIBRARY_PATH

# # [TODO: fix findBOOST in OpenMS installation]
# # add openms to the PATH
# ENV PATH /usr/local/openms-build/bin/:$PATH
	
# create a user
ENV HOME /home/user
RUN mkdir /home/user \
    && adduser -D -h $HOME user \
    && chmod -R u+rwx $HOME \
    && chown -R user:user $HOME

# switch back to user
WORKDIR $HOME
USER user