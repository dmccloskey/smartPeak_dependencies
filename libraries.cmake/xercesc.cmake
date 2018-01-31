##################################################
###       XERCES 															 ###
##################################################
## XERCES from http://xerces.apache.org/xerces-c/
## repacked source files and created VisualStudio 2008 files

MACRO( SMARTPEAK_DEPENDENCIES_BUILD_XERCESC )
  SMARTPEAK_LOGHEADER_LIBRARY("Xerces-C")
  #extract: (takes very long.. so skip if possible)
  if(MSVC)
    set(ZIP_ARGS "x -y -osrc")
  else()
    set(ZIP_ARGS "xzf")
  endif()
  SMARTPEAK_SMARTEXTRACT(ZIP_ARGS ARCHIVE_XERCES "XERCES" "CREDITS")

  if(MSVC)
    # patch to remove gsl vs. xerces bug
    set(PATCH_FILE "${PROJECT_SOURCE_DIR}/patches/xercesc/Xerces_autoconf_config.msvc.hpp.diff")
	  set(PATCHED_FILE "${XERCES_DIR}/src/xercesc/util/Xerces_autoconf_config.msvc.hpp")
	  SMARTPEAK_PATCH( PATCH_FILE XERCES_DIR PATCHED_FILE)

    set(PATCH_FILE "${PROJECT_SOURCE_DIR}/patches/xercesc/XercesDefs.hpp.diff")
	  set(PATCHED_FILE "${XERCES_DIR}/src/xercesc/util/XercesDefs.hpp")
	  SMARTPEAK_PATCH( PATCH_FILE XERCES_DIR PATCHED_FILE)

	  set(PATCH_FILE "${PROJECT_SOURCE_DIR}/patches/xercesc/Version_VS11.diff")
	  set(PATCHED_FILE "${XERCES_DIR}/src/xercesc/util/MsgLoaders/Win32/Version.rc")
	  SMARTPEAK_PATCH( PATCH_FILE XERCES_DIR PATCHED_FILE)

    set(MSBUILD_ARGS_SLN "${XERCES_DIR}/Projects/Win32/VC${CONTRIB_MSVC_VERSION}/xerces-all/xerces-all.sln")
    set(MSBUILD_ARGS_TARGET "XercesLib")
    SMARTPEAK_BUILDLIB("XERCES (Debug)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Debug" XERCES_DIR)
    SMARTPEAK_BUILDLIB("XERCES (Release)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Release" XERCES_DIR)

    ## copy includes (TODO: this is still unclean, as xerces mixed cpp with hpp - we need to copy only *.hpp)
    set(dir_target ${PROJECT_BINARY_DIR}/include/xercesc)
    set(dir_source ${XERCES_DIR}/src/xercesc)
    SMARTPEAK_COPYDIR(dir_source dir_target)

  else() # THE UNIX WAY
    
    # configure
    if( ${CMAKE_SYSTEM_NAME} MATCHES "Darwin" )
      set(XERCESC_EXTRA_FLAGS "--enable-transcoder-macosunicodeconverter --enable-transcoder-gnuiconv --enable-transcoder-iconv --disable-dependency-tracking CFLAGS='${OSX_DEPLOYMENT_FLAG} ${OSX_SYSROOT_FLAG}' CXXFLAGS='${OSX_DEPLOYMENT_FLAG} ${OSX_SYSROOT_FLAG} ${OSX_LIB_FLAG}'")
    else()
      set(XERCESC_EXTRA_FLAGS "--enable-transcoder-gnuiconv --enable-transcoder-iconv")
    endif()

    message( STATUS "Configuring XERCES-C library (./configure --prefix ${CMAKE_BINARY_DIR} --disable-network --disable-transcoder-icu --disable-shared --with-pic ${XERCESC_EXTRA_FLAGS} CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER}) .. ")
    exec_program("./configure" "${XERCES_DIR}"
      ARGS
      --prefix ${CMAKE_BINARY_DIR}
      --disable-network
      --with-pic
      --disable-transcoder-icu
      --disable-shared
      ${XERCESC_EXTRA_FLAGS}
      CXX=${CMAKE_CXX_COMPILER}
      CC=${CMAKE_C_COMPILER}
      OUTPUT_VARIABLE XERCESC_CONFIGURE_OUT
      RETURN_VALUE XERCESC_CONFIGURE_SUCCESS
      )

    # logfile
    file(APPEND ${LOGFILE} ${XERCESC_CONFIGURE_OUT})

    if( NOT XERCESC_CONFIGURE_SUCCESS EQUAL 0)
      message( STATUS "Configuring XERCES-C library (./configure --prefix ${CMAKE_BINARY_DIR} --disable-network --disable-transcoder-icu --disable-shared --with-pic ${XERCESC_EXTRA_FLAGS} CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER}) .. failed")
      message( FATAL_ERROR ${XERCESC_CONFIGURE_OUT})
    else()
      message( STATUS "Configuring XERCES-C library (./configure --prefix ${CMAKE_BINARY_DIR} --disable-network --disable-transcoder-icu --disable-shared --with-pic ${XERCESC_EXTRA_FLAGS} CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER}) .. done")
    endif()

    # make 
    message( STATUS "Building XERCES-C library (make).. ")
    exec_program(${CMAKE_MAKE_PROGRAM} "${XERCES_DIR}"
      ARGS -j ${NUMBER_OF_JOBS}
      OUTPUT_VARIABLE XERCESC_MAKE_OUT
      RETURN_VALUE XERCESC_MAKE_SUCCESS
      )

    # logfile
    file(APPEND ${LOGFILE} ${XERCESC_MAKE_OUT})

    if( NOT XERCESC_MAKE_SUCCESS EQUAL 0)
      message( STATUS "Building XERCES-C library (make) .. failed")
      message( FATAL_ERROR ${XERCESC_MAKE_OUT})
    else()
      message( STATUS "Building XERCES-C library (make) .. done")
    endif()
    
    # make install
    message( STATUS "Installing XERCES-C library (make install) .. ")
    exec_program(${CMAKE_MAKE_PROGRAM} "${XERCES_DIR}"
      ARGS "install"
      -j ${NUMBER_OF_JOBS}
      OUTPUT_VARIABLE XERCESC_INSTALL_OUT
      RETURN_VALUE XERCESC_INSTALL_SUCCESS
      )
    
    # logfile
    file(APPEND ${LOGFILE} ${XERCESC_INSTALL_OUT})

    if( NOT XERCESC_INSTALL_SUCCESS EQUAL 0)
      message( STATUS "Installing XERCES-C library (make install) .. failed")
      message( FATAL_ERROR ${XERCESC_INSTALL_OUT})
    else()
      message( STATUS "Installing XERCES-C library (make install) .. done")      
    endif()
  endif()
ENDMACRO( SMARTPEAK_DEPENDENCIES_BUILD_XERCESC )
