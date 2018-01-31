##################################################
###                  Eigen3                    ###
##################################################

## build and install eigen
macro( SMARTPEAK_DEPENDENCIES_BUILD_EIGEN )

  SMARTPEAK_LOGHEADER_LIBRARY("eigen")
  
  if(MSVC)
    set(ZIP_ARGS "x -y -osrc")
  else()
    set(ZIP_ARGS "xzf")
  endif()
  SMARTPEAK_SMARTEXTRACT(ZIP_ARGS ARCHIVE_EIGEN "EIGEN" "CMakeLists.txt")

  # disable testing using blas libraries
  set(_PATCH_FILE "${PATCH_DIR}/eigen/CMakeList.txt.patch")		
  set(_PATCHED_FILE "${EIGEN_DIR}/CMakeList.txt")		
  SMARTPEAK_PATCH( _PATCH_FILE EIGEN_DIR _PATCHED_FILE)		
  set(_PATCH_FILE "${PATCH_DIR}/eigen/blasCMakeList.txt.patch")		
  set(_PATCHED_FILE "${EIGEN_DIR}/blas/CMakeList.txt")		
  SMARTPEAK_PATCH( _PATCH_FILE EIGEN_DIR _PATCHED_FILE)		
  set(_PATCH_FILE "${PATCH_DIR}/eigen/unsupportedCMakeList.txt.patch")		
  set(_PATCHED_FILE "${EIGEN_DIR}/unsupported/CMakeList.txt")		
  SMARTPEAK_PATCH( _PATCH_FILE EIGEN_DIR _PATCHED_FILE)		

  # eigen doesn't allow insource builds
  set(_EIGEN_BUILD_DIR "${EIGEN_DIR}/build")
  file(TO_NATIVE_PATH "${_EIGEN_BUILD_DIR}" _EIGEN_NATIVE_BUILD_DIR)

  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${_EIGEN_NATIVE_BUILD_DIR})

  message(STATUS "Generating eigen build system .. ")

  execute_process(COMMAND ${CMAKE_COMMAND}
                  -G "${CMAKE_GENERATOR}"
                  -D CMAKE_INSTALL_PREFIX=${PROJECT_BINARY_DIR}
                  -D BUILD_TESTING:BOOL=OFF
                  -D EIGEN_TEST_NOQT=ON
                  ${EIGEN_DIR}
                  WORKING_DIRECTORY ${_EIGEN_NATIVE_BUILD_DIR}
                  OUTPUT_VARIABLE _EIGEN_CMAKE_OUT
                  ERROR_VARIABLE _EIGEN_CMAKE_ERR
                  RESULT_VARIABLE _EIGEN_CMAKE_SUCCESS)

  # output to logfile
  file(APPEND ${LOGFILE} ${_EIGEN_CMAKE_OUT})
  file(APPEND ${LOGFILE} ${_EIGEN_CMAKE_ERR})

  if (NOT _EIGEN_CMAKE_SUCCESS EQUAL 0)
    message(FATAL_ERROR "Generating eigen build system .. failed")
  else()
    message(STATUS "Generating eigen build system .. done")
  endif()

  # the install target on windows has a different name then on mac/lnx
  if(MSVC)
      set(_EIGEN_INSTALL_TARGET "INSTALL")
  else()
      set(_EIGEN_INSTALL_TARGET "install")
  endif()

  message(STATUS "Installing eigen headers .. ")
  execute_process(COMMAND ${CMAKE_COMMAND} --build ${_EIGEN_NATIVE_BUILD_DIR} --target ${_EIGEN_INSTALL_TARGET} --config Release
                  WORKING_DIRECTORY ${_EIGEN_NATIVE_BUILD_DIR}
                  OUTPUT_VARIABLE _EIGEN_BUILD_OUT
                  ERROR_VARIABLE _EIGEN_BUILD_ERR
                  RESULT_VARIABLE _EIGEN_BUILD_SUCCESS)

  # output to logfile
  file(APPEND ${LOGFILE} ${_EIGEN_BUILD_OUT})
  file(APPEND ${LOGFILE} ${_EIGEN_BUILD_ERR})

  if (NOT _EIGEN_BUILD_SUCCESS EQUAL 0)
    message(FATAL_ERROR "Installing eigen headers .. failed")
  else()
    message(STATUS "Installing eigen headers .. done")
  endif()
endmacro( SMARTPEAK_DEPENDENCIES_BUILD_EIGEN )
