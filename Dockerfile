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
ENV OPENMS_VERSION merge/AbsoluteQuantitation
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
    git && \
    # apk del .build-dependencies && \
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
    cmake -DBUILD_TYPE=SEQAN ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=WILDMAGIC ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=EIGEN ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=COINOR ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=ZLIB ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=BZIP2 ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=GLPK ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=LIBSVM ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=SQLITE ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=XERCESC ../smartPeak_dependencies && \
    cmake -DBUILD_TYPE=BOOST ../smartPeak_dependencies
    ## clone the OpenMS repository
    #cd /usr/local/  && \
    #git clone ${OPENMS_REPOSITORY} && \
    #cd /usr/local/OpenMS/ && \
    #git checkout ${OPENMS_VERSION} && \
    #cd /usr/local/ && \
    #mkdir openms-build && \
    #cd /usr/local/openms-build/ && \
    ## build the OpenMS executables
    #cmake -DPYOPENMS=OFF -DCMAKE_PREFIX_PATH="/usr/local/contrib-build/;/usr/local/contrib/;/usr/;/usr/local" -DBOOST_USE_STATIC=OFF -DHAS_XSERVER=Off ../OpenMS && \
    #make -j8

## add openms to the list of libraries
#ENV LD_LIBRARY_PATH /usr/local/openms-build/lib/:$LD_LIBRARY_PATH
## add openms to the PATH
#ENV PATH /usr/local/openms-build/bin/:$PATH
	
# create a user
ENV HOME /home/user
RUN mkdir /home/user \
    && adduser -D -h $HOME user \
    && chmod -R u+rwx $HOME \
    && chown -R user:user $HOME

# switch back to user
WORKDIR $HOME
USER user
