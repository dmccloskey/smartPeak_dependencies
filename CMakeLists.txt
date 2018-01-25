## *** IMPORTANT ***
## when updating the dependencies with new packages:
## GENERAL:
## - make sure to adopt the following variables for each library <LIBNAME>, currently we have
##    * <LIBNAME>_DIR
##    * ARCHIVE_<LIBNAME>
##    * ARCHIVE_<LIBNAME>_TAR
##    * INCLUDE_DIR_<LIBNAME> (or INCLUDE_FILES_<LIBNAME> in the case that there are just files copied to include/ [LIBSVM])
##
## WINDOWS ONLY: [the information below applies only to WINDOWS, but when you update the dependencies you MUST do both Linux, Mac OS X and Windows - so read carefully!]
## - usually each package contains a build-system for Windows (solution [*.sln] files or NMake files [Makefile.win] ) and Linux(Makefiles) already provided by
##   the original developer. In some cases you need to rely on third party packages, e.g. the gsl-win project, which provides solution files.
##   HOWEVER, for Windows they are usually not complete (e.g. missing 64bit targets, or even whole solution files
##   for a certain Visual Studio version (we support 8 and above).
##   Case a: 64bit targets are missing in Solution file
##    Solution: open the VS solution and add x64 solution platform using the Configuration Manager
##                (you can build the x64 target by adding "|64" to the Build option of devenv.exe - see examples below)
##   Case b: Solution files for a certain Visual Studio Version (usually 9) are missing.
##      Solution: copy the VS8 solution (including vcproj files) - usually this is a separate folder
##          using the VS9 IDE, open the copied VS8 solution (a converter tool should automatically open) and follow the steps.
##          (optionally rename the converted solution e.g. from xerces_vs8.sln to xerces_vs9.sln)
## Remember: in the end, you need three solution files (VS8 & VS9 & VS10), each supporting 32 and 64 bit platforms.
##
## Making sure linking is consistent:
##    - when combining external libs with our own, Microsoft's linker can only handle one type of reference to the C(++) standard libs, which is either
##      dynamic (/MD(d)) or static (/MT(d)), but not both (you will get multiply defined symbols and tons of linker errors).
##      Note that this does not mean you cannot mix static and dynamic external libraries (you can), it rather means you cannot mix static and dynamic CRT's.
##      Thus, make sure to check every new solution file you add is linking to the *dynamic* CRT with /MD(d).
##
##
## Alternatively, some projects use NMake-files (libsvm does). There it is easier, because you only need one Makefile.win file for all four cases.
## Be aware though that including object files (*.obj) in Visual Studio is not supported by SmartPeak/CMake, you thus will need to create a lib
## (see libsvm Makefile.win for an example)
##
##
## Where do I get Windows-packages with at least partially complete solution files?
## Boost:  NA, Boost uses its in-house Boost-Jam which supports everything we need
## SEQAN:  headers only library, no compilation necessary for SmartPeak
## LibSVM: comes with a Makefile.win, but libsvm needed some serious tweaking to support debug mode and to build a lib (instead of object files only)
## XERCES-C: they offer a VS version on their website (http://xerces.apache.org/xerces-c/), usually not for bleeding edge release though - bad luck for us.
## GSL:    get the src package from http://gnuwin32.sourceforge.net/packages/gsl.htm,
##         This should still contain the Linux Makefiles.
## GLPK:   download from http://ftp.gnu.org/gnu/glpk/glpk-4.46.tar.gz
## COIN-OR: we use the CoinMP package available from
##         http://www.coin-or.org/download/source/CoinMP/CoinMP-1.3.3.tgz


## some words:
## Patching: We do not (by intention) use a ".is_patched" file, but let patch(.exe) handle create a .orig file, which is in the same location as the patched file

## required software:
## Windows: 7-Zip & GNUWin32-patch
## Linux & MinGW: Tar & patch
## (these are searched for and an appropriate error message is given when not found)


## NOTE: remove "exec_program" calls and substitute with exec_process (see http://www.cmake.org/cmake/help/cmake2.6docs.html#command:execute_process)
##       - however: exec_process seems to handle our arguments incorrectly (at least on Windows). Check functionality before you commit!

# Determine what to build (all or single library)
set( BUILD_TYPE LIST CACHE STRING "Can be used to restrict building to a single library: ALL,SEQAN,LIBSVM,XERCESC,BOOST,GSL,COINOR,BZIP2,ZLIB,GLPK,KISSFFT")
set( VALID_BUILD_TYPES "ALL" "SEQAN" "LIBSVM" "XERCESC" "BOOST" "COINOR" "BZIP2" "ZLIB" "GLPK" "EIGEN" "WILDMAGIC" "SQLITE" "KISSFFT")

# check build type
if (BUILD_TYPE STREQUAL "HELP" OR BUILD_TYPE STREQUAL "LIST")
  message(STATUS "===========================================================================")
  message(STATUS " SmartPeak dependencies (dependency packages) installation.")
  message(STATUS " This program will allow you to compile and install all of the SmartPeak")
  message(STATUS " dependencies. Select the package you wish to install using the the command")
  message(STATUS " -DBUILD_TYPE= or install all of them with -DBUILD_TYPE=ALL.")
  message(STATUS "===========================================================================")
  message(STATUS "Valid BUILD_TYPEs are:")
  foreach( BT ${VALID_BUILD_TYPES} )
    message(STATUS " * ${BT}")
  endforeach( BT VALID_BUILD_TYPES )
  return(0)
endif()

PROJECT("SmartPeak_DEPENDENCIES")

# Heart of the BUILD system : only edit when you know what you are doing (we don't)
# quick manual for most commands: http://www.cmake.org/cmake/help/cmake2.6docs.html
# useful predefined variables: http://www.paraview.org/Wiki/CMake_Useful_Variables

# force cmake > 3.1 to force enable c11 support
cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)

SET(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS true)

# Set C++ version
SET(CMAKE_CXX_STANDARD 11)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)

## sanity checks:

## no MSYS/MINGW
if (MINGW OR MSYS) ## only happens on Windows
  message(FATAL_ERROR "MSYS and/or MinGW are not supported! Please use a Visual Studio environment! See Windows build instructions for further information!")
endif()

## do not allow source or binary directories with spaces
## The dependencies can basically handle those (make sure to wrap calls in quotes where appropriate) but e.g. BOOST under windows cannot

string(REPLACE " " "" PROJECT_BINARY_DIR_NOSPACES ${PROJECT_BINARY_DIR})
if (NOT ${PROJECT_BINARY_DIR} STREQUAL ${PROJECT_BINARY_DIR_NOSPACES})
  message(FATAL_ERROR "The current dependencies binary directory contains spaces, which are not allowed. Build the dependencies in another directory!")
endif()
string(REPLACE " " "" PROJECT_SOURCE_DIR_NOSPACES ${PROJECT_SOURCE_DIR})
if (NOT ${PROJECT_SOURCE_DIR} STREQUAL ${PROJECT_SOURCE_DIR_NOSPACES})
  message(FATAL_ERROR "The current dependencies binary directory contains spaces, which are not allowed. Build the dependencies in another directory!")
endif()

## target directories
set (DEPENDENCIES_BIN_SOURCE_DIR "${PROJECT_BINARY_DIR}/src" CACHE STRING "Directory inside the binary tree where the (extracted) dependencies sources are located")
set (DEPENDENCIES_BIN_INCLUDE_DIR "${PROJECT_BINARY_DIR}/include" CACHE STRING "Directory inside the binary tree where the dependencies includes are located")
set (DEPENDENCIES_BIN_LIB_DIR "${PROJECT_BINARY_DIR}/lib" CACHE STRING "Directory inside the binary tree where the dependencies libs are located")
set (PATCH_DIR "${PROJECT_SOURCE_DIR}/patches/" CACHE STRING "Directory containing all the patch files")

# project specific source directories
## Warning: ensure these are all upper-case names!
set(BZIP2_DIR ${DEPENDENCIES_BIN_SOURCE_DIR}/bzip2-1.0.5)
set(ZLIB_DIR ${DEPENDENCIES_BIN_SOURCE_DIR}/zlib-1.2.8)
set(BOOST_DIR ${DEPENDENCIES_BIN_SOURCE_DIR}/boost_1_64_0)
set(GLPK_DIR ${DEPENDENCIES_BIN_SOURCE_DIR}/glpk-4.46)
set(COINOR_DIR ${DEPENDENCIES_BIN_SOURCE_DIR}/CoinMP-1.8.3)
set(WILDMAGIC_DIR ${DEPENDENCIES_BIN_SOURCE_DIR}/WildMagic5)
set(SQLITE_DIR ${DEPENDENCIES_BIN_SOURCE_DIR}/sqlite-autoconf-3150000)


## source(archive) paths
## PLEASE upload all source archives to
##     http://ftp.mi.fu-berlin.de/pub/SmartPeak/dependencies-sources/
## and provide the necessary information below
##  ARCHIVE_<LIBNAME> the name of the archive as it was uploaded
##  ARCHIVE_<LIBNAME>_TAR the name of the tar in the tar.gz
##  ARCHIVE_<LIBNAME>_SHA1 the sha1 of the file uploaded to sourceforge
## e.g.
##  set(ARCHIVE_ZLIB zlib.tar.gz)
##  set(ARCHIVE_ZLIB_TAR zlib.tar)
##  set(ARCHIVE_ZLIB_SHA1 "8e8b93fa5eb80df1afe5422309dca42964562d7e")
## NOTE: for local development you can simply place the *.tar.gz in the binary
##       directory to prevent the download and sha1 verification

set(ARCHIVE_BZIP2 bzip2-1.0.5.tar.gz)
set(ARCHIVE_BZIP2_TAR bzip2-1.0.5.tar)
set(ARCHIVE_BZIP2_SHA1 "8b02713ea0c8eb501cc8bdac4432d7f29700f767")

set(ARCHIVE_ZLIB zlib-1.2.8.tar.gz)
set(ARCHIVE_ZLIB_TAR  zlib-1.2.8.tar)
set(ARCHIVE_ZLIB_SHA1 "a4d316c404ff54ca545ea71a27af7dbc29817088")

set(ARCHIVE_BOOST boost_1_64_0.tar.gz)
set(ARCHIVE_BOOST_TAR  boost_1_64_0.tar)
set(ARCHIVE_BOOST_SHA1 "6d983895e738e35b73c3a40b605080c4b64114e9")

set(ARCHIVE_GLPK glpk-4.46.tar.gz)
set(ARCHIVE_GLPK_TAR  glpk-4.46.tar)
set(ARCHIVE_GLPK_SHA1 "73d589452dc1d8d6a784b3f86f4268cae37420d7")

set(ARCHIVE_COINOR CoinMP-1.8.3-vs17.tar.gz)
set(ARCHIVE_COINOR_TAR  CoinMP-1.8.3.tar)
set(ARCHIVE_COINOR_SHA1 "3a6374a9dc4bb22e1ca4266dc16776c37eeef43c")

set(ARCHIVE_WILDMAGIC WildMagic5.tar.gz)
set(ARCHIVE_WILDMAGIC_TAR  WildMagic5.tar)
set(ARCHIVE_WILDMAGIC_SHA1 "e30b6f7f955c640dadfea09385a0a0ddec5b2997")

set(ARCHIVE_SQLITE sqlite-autoconf-3150000.tar.gz)
set(ARCHIVE_SQLITE_TAR  sqlite-autoconf-3150000.tar)
set(ARCHIVE_SQLITE_SHA1 "b34cb4ee9710368598c62df0222f5c24dfc9c860")

## necessary for clean up .. change if install process of library changes
set(INCLUDE_DIR_BOOST ${DEPENDENCIES_BIN_INCLUDE_DIR}/boost)
set(INCLUDE_DIR_GLPK ${DEPENDENCIES_BIN_INCLUDE_DIR}/GLPK)
set(INCLUDE_DIR_COINOR ${DEPENDENCIES_BIN_INCLUDE_DIR}/coin)
set(INCLUDE_DIR_WILDMAGIC ${DEPENDENCIES_BIN_INCLUDE_DIR}/WildMagic5)

## hack for simple libs that do not have include directories
set(INCLUDE_FILES_BZIP2 ${DEPENDENCIES_BIN_INCLUDE_DIR}/bzlib.h ${DEPENDENCIES_BIN_INCLUDE_DIR}/bzlib_private.h)
set(INCLUDE_FILES_ZLIB ${DEPENDENCIES_BIN_INCLUDE_DIR}/zlib.h)
set(INCLUDE_FILES_SQLITE ${DEPENDENCIES_BIN_INCLUDE_DIR}/sqlite3.h)

## address model of dependencies
if (CMAKE_SIZEOF_VOID_P MATCHES "8")
  set(DEPENDENCIES_ADDRESSMODEL 64 CACHE INTERNAL "Architecture-bits")
else()
  set(DEPENDENCIES_ADDRESSMODEL 32 CACHE INTERNAL "Architecture-bits")
endif()
message(STATUS "ADDRESSMODEL IS: ${DEPENDENCIES_ADDRESSMODEL} bit")
if (NOT DEPENDENCIES_ADDRESSMODEL MATCHES "32|64")
  Message(FATAL_ERROR "DEPENDENCIES_ADDRESSMODEL is neither 32 nor 64! Please correct this!")
endif()

# logfile
set(LOGFILE "${PROJECT_BINARY_DIR}/dependencies_build.log")

if (MSVC)
  ## guess MSVC Version (we need this in order to correctly guess the names of the VS solution targets.
  ## Since CMake 3.0 you can use the years (e.g. 2013) for every VS version. For VS 8 and 9 you have to use the year!
  if (CMAKE_GENERATOR MATCHES ".*Visual Studio 8 2005.*")
    set(TMP_MSVC_VERSION "8")
  elseif (CMAKE_GENERATOR MATCHES ".*Visual Studio 9 2008.*")
    set(TMP_MSVC_VERSION "9")
  elseif (CMAKE_GENERATOR MATCHES ".*Visual Studio 10.*")
    set(TMP_MSVC_VERSION "10")
  elseif (CMAKE_GENERATOR MATCHES ".*Visual Studio 11.*")
    set(TMP_MSVC_VERSION "11")
  elseif (CMAKE_GENERATOR MATCHES ".*Visual Studio 12.*")
    set(TMP_MSVC_VERSION "12")
  elseif (CMAKE_GENERATOR MATCHES ".*Visual Studio 14.*")
    set(TMP_MSVC_VERSION "14")
  elseif (CMAKE_GENERATOR MATCHES ".*Visual Studio 15.*")
    set(TMP_MSVC_VERSION "15")
  else()
    if (OVERRIDE_GENERATOR)
      message(FATAL_ERROR "Chosen to override the Generator check, proceed with caution.")
    else()
      message(FATAL_ERROR "Please use 'Visual Studio ?? [Win64]' (??={8 2005, 9 2008, 10, 11, 12, 14, 15}) as Generator - identical to the MSVC toolchain you plan to use for SmartPeak! Note that you must not use NMake or alike for the dependencies (nor for SmartPeak). There will be errors (mostly missing libraries). Under very special circumstances, you can override this with -DOVERRIDE_GENERATOR=On.")
    endif()
  endif()
  set(DEPENDENCIES_MSVC_VERSION ${TMP_MSVC_VERSION} CACHE INTERNAL "Microsoft Visual Studio Version used. Valid values: 8 and above")
  ## parameter validity check
  message(STATUS "MSVC Version is: ${DEPENDENCIES_MSVC_VERSION}")

  ## some settings for Building the libs
  if (DEPENDENCIES_ADDRESSMODEL MATCHES 32)
    set(BOOST_ARG "")
    set(WIN_PLATFORM_ARG "Win32")
  else()
    set(BOOST_ARG "address-model=64")
    set(WIN_PLATFORM_ARG "x64")
  endif()

  find_program(PROGRAM_ZIP "7z.exe" PATHS "C:/Program Files/7-Zip" "C:/Programme/7-Zip")
  if (NOT PROGRAM_ZIP)
    message(FATAL_ERROR "Cannot find '7z.exe' on your system. Please install 7-zip and add the directory to your PATH environment variable!")
  endif()

  ## http://gnuwin32.sourceforge.net/packages/patch.htm
  find_program(PROGRAM_PATCH "patch.exe" PATHS "C:/Program Files/gnuwin32/bin" "C:/Program Files/patch/bin" "${PROJECT_SOURCE_DIR}/tools")
  if (NOT PROGRAM_PATCH)
    message(FATAL_ERROR "Cannot find 'patch.exe' on your system. Please install gnuwin32-patch and add the directory to your PATH environment variable!")
  endif()

  find_program(MSBUILD_EXECUTABLE MSBuild PATHS "C:/Program Files (x86)/MSBuild/${DEPENDENCIES_MSVC_VERSION}.0/Bin/")
  if (MSBUILD_EXECUTABLE)
    message(STATUS "Finding MSBuild.exe (usually installed along with .NET or VS [since 12] ) ... success")
  else()
    message(STATUS "Finding MSBuild.exe (usually installed along with .NET or VS [since 12]) ... failed")
    message(STATUS "\n\nIf not shipped with your Visual Studio version (e.g. <12), please install Microsoft .NET (3.5 or above) and/or make sure MSBuild.exe is in your PATH!\n")
	message(STATUS "More recent versions of Visual Studio will install MSBuild in its own directory, e.g. 'C:\Program Files (x86)\MSBuild\${DEPENDENCIES_MSVC_VERSION}.0\Bin\'. We looked there, but maybe it's slightly different...\n")
    message(FATAL_ERROR ${MSBUILD_EXECUTABLE})
  endif()
  
  ## just check if nmake is present -- if not later package calls will fail
  find_program(NMAKE_EXECUTABLE nmake.exe)
  if (NMAKE_EXECUTABLE)
    message(STATUS "Finding nmake.exe (as part of VS) ... success")
  else()
    message(STATUS "Finding nmake.exe (usually installed along with VS ... failed")
    message(STATUS "\n\nAre you sure you are using a VS developer(!) command line (which has more entries in %PATH%) and not just a normal command line?\n")
    message(FATAL_ERROR ${NMAKE_EXECUTABLE})
  endif()
  
else() ## linux/Mingw/macos
  # tar
  find_program(PROGRAM_ZIP "tar")
  if (NOT PROGRAM_ZIP)
    message(FATAL_ERROR "Cannot find 'tar' on your system. Please install the tar program and add the directory to your PATH environment variable!")
  endif()

  # patch
  find_program(PROGRAM_PATCH "patch")
  if (NOT PROGRAM_PATCH)
    message(FATAL_ERROR "Cannot find 'patch' on your system. Please install patch and add the directory to your PATH environment variable!")
  endif()

  ## following progs are required for xerces-c, since we build from svn and not a release
  # autoconf
  find_program(PROGRAM_AUTOCONF "autoconf")
  if (NOT PROGRAM_AUTOCONF)
    message(FATAL_ERROR "Cannot find 'autoconf' on your system. Please install autoconf and add the directory to your PATH environment variable!")
  endif()

  # automake
  find_program(PROGRAM_AUTOMAKE "automake")
  if (NOT PROGRAM_AUTOMAKE)
    message(FATAL_ERROR "Cannot find 'automake' on your system. Please install automake and add the directory to your PATH environment variable!")
  endif()

  # libtoolize
  find_program(PROGRAM_LIBTOOLIZE NAMES "libtoolize" "glibtoolize")
  if (NOT PROGRAM_LIBTOOLIZE)
    message(FATAL_ERROR "Cannot find '(g)libtoolize' on your system. Please install libtoolize and add the directory to your PATH environment variable!")
  endif()

  # touch
  find_program(PROGRAM_TOUCH "touch")
  if (NOT PROGRAM_TOUCH)
    message(FATAL_ERROR "Cannot find 'touch' on your system. Please install touch and add the directory to your PATH environment variable!")
  endif()

endif()

## prepare
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/lib")
file(MAKE_DIRECTORY "${DEPENDENCIES_BIN_SOURCE_DIR}")
file(MAKE_DIRECTORY "${DEPENDENCIES_BIN_INCLUDE_DIR}")

## initial log values
file(WRITE ${LOGFILE} "-- Starting to build dependencies --\n\r")
file(APPEND ${LOGFILE} "CXX: ${CMAKE_CXX_COMPILER}\n\r")
file(APPEND ${LOGFILE} "CC: ${CMAKE_C_COMPILER}\n\r")

## macOS specifics.
if(APPLE)
  if( CMAKE_OSX_DEPLOYMENT_TARGET )
  message(STATUS "Deployment target for OSX was set to ${CMAKE_OSX_DEPLOYMENT_TARGET}. Adding the following flags whenever possible/needed:\n\r")
    set( OSX_DEPLOYMENT_TARGET_STRING "macosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
    set( OSX_DEPLOYMENT_FLAG "-m${OSX_DEPLOYMENT_TARGET_STRING}")
    if( NOT (${CMAKE_SYSTEM_VERSION} LESS 13))
      ## Later than OSX 10.9 when they switched to libc++ as standard library
      set( OSX_LIB_FLAG "-stdlib=libc++")
    else()
      set( OSX_LIB_FLAG "-stdlib=libstdc++")
    endif()
    message(STATUS "${OSX_DEPLOYMENT_FLAG} ${OSX_LIB_FLAG}")
  endif()

  if( CMAKE_OSX_SYSROOT )
    message(STATUS "Sysroot for OSX was set to ${CMAKE_OSX_SYSROOT}. Adding the following flags whenever possible/needed:\n\r")
    set( OSX_SYSROOT_STRING "sysroot=${CMAKE_OSX_SYSROOT}")
    set( OSX_SYSROOT_FLAG "--${OSX_SYSROOT_STRING}")
    message(STATUS "${OSX_SYSROOT_FLAG}")
  endif()

  # force cmake > 3.1 to force enable c11 support
cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)
endif()

## include extract/patch/build macros
include ("${CMAKE_SOURCE_DIR}/macros.cmake")
include ("${CMAKE_SOURCE_DIR}/libraries.cmake/boost.cmake")
include ("${CMAKE_SOURCE_DIR}/libraries.cmake/glpk.cmake")
include ("${CMAKE_SOURCE_DIR}/libraries.cmake/bzip2.cmake")
include ("${CMAKE_SOURCE_DIR}/libraries.cmake/zlib.cmake")
include ("${CMAKE_SOURCE_DIR}/libraries.cmake/coinor.cmake")
include ("${CMAKE_SOURCE_DIR}/libraries.cmake/wildmagic.cmake")
include ("${CMAKE_SOURCE_DIR}/libraries.cmake/sqlite.cmake")

## build mac os x specific C/C++ flags
set( SMARTPEAK_DEPENDENCIES_MACOSX_MIXED_MODE 0 CACHE INTERNAL "building multiple architectures on MacOSX" FORCE)

list(FIND VALID_BUILD_TYPES ${BUILD_TYPE} list_pos)
if( ${list_pos} EQUAL -1 )
  message(STATUS "The BUILD_TYPE ${BUILD_TYPE} is invalid")
  message(STATUS "Valid BUILD_TYPEs are:")
  foreach( BT ${VALID_BUILD_TYPES} )
    message(STATUS " * ${BT}")
  endforeach( BT VALID_BUILD_TYPES )
  message(FATAL_ERROR "Aborting dependencies build!")
else( ${list_pos} EQUAL -1 )
  message(STATUS "BUILD_TYPE: ${BUILD_TYPE} (one of: ${VALID_BUILD_TYPES})")
endif( ${list_pos} EQUAL -1 )

set( FORCE_REBUILD OFF CACHE BOOL "All installation and build traces of the dependencies packages will be removed before building.")
message(STATUS "FORCE_REBUILD: ${FORCE_REBUILD}")

set( NUMBER_OF_JOBS 2 CACHE STRING "Number of jobs executed in parallel during the build process if the build system supports multi-job builds (e.g., make, bjam)")
if("${NUMBER_OF_JOBS}" STREQUAL "")
  set( NUMBER_OF_JOBS 1 )
endif("${NUMBER_OF_JOBS}" STREQUAL "")
message(STATUS "NUMBER_OF_JOBS: ${NUMBER_OF_JOBS} (maximal number of concurrent compile jobs)")

## define building of shared or unshared versions of the dependencies libraries
set( BUILD_SHARED_LIBRARIES Off CACHE BOOL "Builds all dependencies libraries as shared libraries.")

##################################################
###       BZIP2                                ###
##################################################

if (BUILD_TYPE STREQUAL "ALL" OR BUILD_TYPE STREQUAL "BZIP2")
  SMARTPEAK_CLEAN_LIB("BZIP2")
  SMARTPEAK_DEPENDENCIES_BUILD_BZIP2()
endif()

##################################################
###       ZLIB                                 ###
##################################################

if (BUILD_TYPE STREQUAL "ALL" OR BUILD_TYPE STREQUAL "ZLIB")
  SMARTPEAK_CLEAN_LIB("ZLIB")
  SMARTPEAK_DEPENDENCIES_BUILD_ZLIB()
endif()

##################################################
###       BOOST                                ###
##################################################

if (BUILD_TYPE STREQUAL "ALL" OR BUILD_TYPE STREQUAL "BOOST")
  SMARTPEAK_CLEAN_LIB("BOOST")
  SMARTPEAK_DEPENDENCIES_BUILD_BOOST()
endif()


##################################################
###       GLPK                                 ###
##################################################

if (BUILD_TYPE STREQUAL "ALL" OR BUILD_TYPE STREQUAL "GLPK")
  SMARTPEAK_CLEAN_LIB("GLPK")
  SMARTPEAK_DEPENDENCIES_BUILD_GLPK()
  SMARTPEAK_COPY_LIBS("GLPK")
endif()

##################################################
###       COIN-OR                              ###
##################################################

if (BUILD_TYPE STREQUAL "ALL" OR BUILD_TYPE STREQUAL "COINOR")
  SMARTPEAK_CLEAN_LIB("COINOR")
  SMARTPEAK_DEPENDENCIES_BUILD_COINOR()
  SMARTPEAK_COPY_LIBS("COINOR")
endif()

##################################################
###       WILDMAGIC                            ###
##################################################

if (BUILD_TYPE STREQUAL "ALL" OR BUILD_TYPE STREQUAL "WILDMAGIC")
  SMARTPEAK_CLEAN_LIB("WILDMAGIC")
  SMARTPEAK_DEPENDENCIES_BUILD_WILDMAGIC()
  SMARTPEAK_COPY_LIBS("WILDMAGIC")
endif()

##################################################
###       SQLITE                               ###
##################################################

if (BUILD_TYPE STREQUAL "ALL" OR BUILD_TYPE STREQUAL "SQLITE")
  SMARTPEAK_CLEAN_LIB("SQLITE")
  SMARTPEAK_DEPENDENCIES_BUILD_SQLITE()
  SMARTPEAK_COPY_LIBS("SQLITE")
endif()

## finally copy README.txt to project-binary directory to mark process complete
configure_file("${PROJECT_SOURCE_DIR}/README.md" "${PROJECT_BINARY_DIR}/README_dependencies.txt"  COPYONLY)