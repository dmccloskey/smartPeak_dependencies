##################################################
###       ZLIB   							   ###
##################################################

MACRO( SMARTPEAK_DEPENDENCIES_BUILD_ZLIB )
  SMARTPEAK_LOGHEADER_LIBRARY("zlib")
  #extract: (takes very long.. so skip if possible)
  if(MSVC)
    set(ZIP_ARGS "x -y -osrc")
  else()
    set(ZIP_ARGS "xzf")
  endif()
  SMARTPEAK_SMARTEXTRACT(ZIP_ARGS ARCHIVE_ZLIB "ZLIB" "README")
	
  ## build the obj/lib
  if (MSVC)
    # fixing static build problem
    if(NOT BUILD_SHARED_LIBRARIES)			
        set(PATCH_FILE "${PATCH_DIR}/zlib/zlib_cmakelists.diff")
        set(PATCHED_FILE "${ZLIB_DIR}/CMakeLists.txt")
        SMARTPEAK_PATCH( PATCH_FILE ZLIB_DIR PATCHED_FILE)
    endif()
		
    message(STATUS "Generating zlib build system .. ")
    execute_process(COMMAND ${CMAKE_COMMAND}
                            -D BUILD_SHARED_LIBS=${BUILD_SHARED_LIBRARIES}
                            -G "${CMAKE_GENERATOR}"
                            -D CMAKE_INSTALL_PREFIX=${PROJECT_BINARY_DIR}
                            ${ZLIB_EXTRA_CMAKE_FLAG}
                            .
                    WORKING_DIRECTORY ${ZLIB_DIR}
                    OUTPUT_VARIABLE ZLIB_CMAKE_OUT
                    ERROR_VARIABLE ZLIB_CMAKE_ERR
                    RESULT_VARIABLE ZLIB_CMAKE_SUCCESS)

		# output to logfile
		file(APPEND ${LOGFILE} ${ZLIB_CMAKE_OUT})
		file(APPEND ${LOGFILE} ${ZLIB_CMAKE_ERR})

		if (NOT ZLIB_CMAKE_SUCCESS EQUAL 0)
			message(FATAL_ERROR "Generating zlib build system .. failed")
		else()
			message(STATUS "Generating zlib build system .. done")
		endif()

		message(STATUS "Building zlib lib (Debug) .. ")
		execute_process(COMMAND ${CMAKE_COMMAND} --build ${ZLIB_DIR} --target INSTALL --config Debug
										WORKING_DIRECTORY ${ZLIB_DIR}
										OUTPUT_VARIABLE ZLIB_BUILD_OUT
										ERROR_VARIABLE ZLIB_BUILD_ERR
										RESULT_VARIABLE ZLIB_BUILD_SUCCESS)

		# output to logfile
		file(APPEND ${LOGFILE} ${ZLIB_BUILD_OUT})
		file(APPEND ${LOGFILE} ${ZLIB_BUILD_ERR})

		if (NOT ZLIB_BUILD_SUCCESS EQUAL 0)
			message(FATAL_ERROR "Building zlib lib (Debug) .. failed")
		else()
			message(STATUS "Building zlib lib (Debug) .. done")
		endif()

		# rebuild as release
		message(STATUS "Building zlib lib (Release) .. ")
		execute_process(COMMAND ${CMAKE_COMMAND} --build ${ZLIB_DIR} --target INSTALL --config Release
										WORKING_DIRECTORY ${ZLIB_DIR}
										OUTPUT_VARIABLE ZLIB_BUILD_OUT
										ERROR_VARIABLE ZLIB_BUILD_ERR
										RESULT_VARIABLE ZLIB_BUILD_SUCCESS)
		# output to logfile
		file(APPEND ${LOGFILE} ${ZLIB_BUILD_OUT})
		file(APPEND ${LOGFILE} ${ZLIB_BUILD_ERR})

		if (NOT ZLIB_BUILD_SUCCESS EQUAL 0)
			message(FATAL_ERROR "Building zlib lib (Release) .. failed")
		else()
			message(STATUS "Building zlib lib (Release) .. done")
		endif()
  
	else() ## Linux/MacOS  

    # CFLAGS for libsvm compiler (see libsvm Makefile)
    set(ZLIB_CFLAGS "-Wall -O3 -fPIC")

    # add OS X specific flags
    if( APPLE )
      set(ZLIB_CFLAGS "${ZLIB_CFLAGS} ${OSX_DEPLOYMENT_FLAG} ${OSX_SYSROOT_FLAG}")
      set(OLD_CFLAGS $ENV{CFLAGS})
      set(ENV{CFLAGS} "-O3 ${OSX_SYSROOT_FLAG}")
    endif( APPLE )

	# configure with with prefix
    message( STATUS "Configuring zlib library (./configure --prefix=${CMAKE_BINARY_DIR}) .. ")
    exec_program("./configure" ${ZLIB_DIR}
      ARGS
      --prefix=${CMAKE_BINARY_DIR}
      OUTPUT_VARIABLE ZLIB_CONFIGURE_OUT
      RETURN_VALUE ZLIB_CONFIGURE_SUCCESS
      )  

	# logfile
    file(APPEND ${LOGFILE} ${ZLIB_CONFIGURE_OUT})

    if( NOT ZLIB_CONFIGURE_SUCCESS EQUAL 0)
      message( STATUS "Configuring zlib library (./configure --prefix=${CMAKE_BINARY_DIR}) .. failed")
      message( FATAL_ERROR ${ZLIB_CONFIGURE_OUT})
    else()
      message( STATUS "Configuring zlib library (./configure --prefix=${CMAKE_BINARY_DIR}) .. done")
    endif()
		

	# make
    message(STATUS "Building zlib library (make CFLAGS='${ZLIB_CFLAGS}') .. ")
    exec_program(${CMAKE_MAKE_PROGRAM} ${ZLIB_DIR}
      ARGS # setting compiler and flags
      clean all
      # We let ./configure choose the compiler, lets not interfere
      # CC=${CMAKE_C_COMPILER}
      CFLAGS='${ZLIB_CFLAGS}'
      OUTPUT_VARIABLE ZLIB_MAKE_OUT
      RETURN_VALUE BUILD_SUCCESS)

    # logfile
    file(APPEND ${LOGFILE} ${ZLIB_MAKE_OUT})
    if (NOT BUILD_SUCCESS EQUAL 0)
        message(STATUS "Building zlib library (make CFLAGS='${ZLIB_CFLAGS}') .. failed")
	    message(FATAL_ERROR ${ZLIB_MAKE_OUT})
    else()
      message(STATUS "Building zlib library (make CFLAGS='${ZLIB_CFLAGS}') .. done")
	endif()
    
    # make install
    message( STATUS "Installing zlib library (make install) .. ")
    exec_program(${CMAKE_MAKE_PROGRAM} "${ZLIB_DIR}"
                ARGS "install"
    OUTPUT_VARIABLE ZLIB_INSTALL_OUT
    RETURN_VALUE ZLIB_INSTALL_SUCCESS
    )

	# logfile
    file(APPEND ${LOGFILE} ${ZLIB_INSTALL_OUT})

    if( NOT ZLIB_INSTALL_SUCCESS EQUAL 0)
      message( STATUS "Installing zlib library (make install) .. failed")
      message( FATAL_ERROR ${ZLIB_INSTALL_OUT})
    else()
      message( STATUS "Installing zlib library (make install) .. done")
    endif()
    
    if( APPLE )
      set(ENV{CFLAGS} ${OLD_CFLAGS})
    endif( APPLE )

endif()

ENDMACRO( SMARTPEAK_DEPENDENCIES_BUILD_ZLIB )
