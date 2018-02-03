# Dockerfile to build SmartPeak images

# Add python3_scientific
FROM dmccloskey/openmsdep

# File Author / Maintainer
LABEL maintainer Douglas McCloskey <dmccloskey87@gmail.com>

# Switch to root for install
USER root

# SmartPeak versions
ENV SMARTPEAK_DEPENDENCIES_VERSION feature/openms

# Clone the SmartPeak/dependencies repository
RUN cd /usr/local/  && \
    rm -r smartPeak_dependencies && \
    git clone https://github.com/dmccloskey/smartPeak_dependencies.git && \
    cd /usr/local/smartPeak_dependencies && \
    git checkout ${SMARTPEAK_DEPENDENCIES_VERSION} && \
    # Build SmartPeak/dependencies
    cd /usr/local/contrib-build/  && \
    cmake -DBUILD_TYPE=OPENMS ../smartPeak_dependencies

# switch back to user
WORKDIR $HOME
USER user
