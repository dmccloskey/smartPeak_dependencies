# Dockerfile to build SmartPeak images

# Add python3_scientific
FROM dmccloskey/cmake

# File Author / Maintainer
LABEL maintainer Douglas McCloskey <dmccloskey87@gmail.com>

# Switch to root for install
USER root

# SmartPeak versions
ENV SMARTPEAK_DEPENDENCIES_VERSION feature/openms

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

# switch back to user
WORKDIR $HOME
USER user
