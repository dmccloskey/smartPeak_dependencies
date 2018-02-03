include (ExternalProject)

# set(INCLUDE_DIR_OPENMS ${DEPENDENCIES_BIN_INCLUDE_DIR}/OpenMS)
set(OPENMS_SOURCE_DIR ${DEPENDENCIES_BIN_SOURCE_DIR}/OpenMS)
set(OPENMS_BINARY_DIR ${DEPENDENCIES_BIN_BINARY_DIR}/OpenMS)


if (WIN32)
  set(OPENMS_MAKE gmake)
else (WIN32)
  set(OPENMS_MAKE make)
endif (WIN32)

ExternalProject_Add(openms
    GIT_REPOSITORY https://github.com/OpenMS/OpenMS
    GIT_TAG develop
    SOURCE_DIR ${OPENMS_SOURCE_DIR}
    CMAKE_ARGS 
        -DPYOPENMS=OFF
        -DCMAKE_PREFIX_PATH="/usr/local/contrib-build/;/usr/local/contrib/;/usr/;/usr/local"
        -DBOOST_USE_STATIC=OFF
        -DHAS_XSERVER=OFF
        -DWITH_GUI=OFF
    BINARY_DIR ${OPENMS_BINARY_DIR}
    BUILD_COMMAND ${OPENMS_MAKE}
    INSTALL_DIR ${INCLUDE_DIR_OPENMS}
    INSTALL_COMMAND install
)
