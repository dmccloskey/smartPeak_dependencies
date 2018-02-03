include (ExternalProject)

# set(INCLUDE_DIR_OPENMS ${DEPENDENCIES_BIN_INCLUDE_DIR}/OpenMS)
set(OPENMS_SOURCE_DIR ${DEPENDENCIES_BIN_SOURCE_DIR}/OpenMS)
set(OPENMS_BINARY_DIR ${DEPENDENCIES_BIN_BINARY_DIR}/OpenMS)
    #BINARY_DIR ${OPENMS_BINARY_DIR}


if (WIN32)
  set(OPENMS_MAKE gmake)
  set(OPENMS_INSTALL gmake install)
else (WIN32)
  set(OPENMS_MAKE make)
  set(OPENMS_INSTALL make install)
endif (WIN32)

ExternalProject_Add(openms
    GIT_REPOSITORY "https://github.com/OpenMS/OpenMS"
    GIT_TAG "develop"
    SOURCE_DIR ${OPENMS_SOURCE_DIR}
    CMAKE_ARGS 
        -DPYOPENMS=OFF
        -DCMAKE_PREFIX_PATH="/usr/local/contrib-build/;/usr/local/contrib/;/usr/;/usr/local"
        -DBOOST_USE_STATIC=OFF
        -DHAS_XSERVER=OFF
        -DWITH_GUI=OFF
    #INARY_DIR ${OPENMS_BINARY_DIR}
    BUILD_IN_SOURCE ON
    BUILD_COMMAND ${OPENMS_MAKE}
    INSTALL_DIR ${INCLUDE_DIR_OPENMS}
    INSTALL_COMMAND ${OPENMS_INSTALL}
)
