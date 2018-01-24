# MIT License
#
# Copyright (c) 2018 Joerg Hallmann
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# https://github.com/joerghall/cbt-components-misc
#
cmake_minimum_required(VERSION 3.5)

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/_submodules/cbt/cmake/setup.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/_submodules/cbt/cmake/setup.cmake)
else ()
    message(FATAL_ERROR "Unable to find buildtools, please check if the submodule is initialized")
endif ()

add_toolset(python2 2.7.14.43.rcd588a99 config=default )
add_toolset(ninja 1.8.2.11.rc3e3b700 config=default )
# add_toolset(pigz 1.8.2.7.r8fe061a4 config=default OVERRIDE_VERSION_WINDOWS=2.3.1)


include(python2)

set(CMAKE_CXX_STANDARD 14)

project(cbt-components-misc)

enable_testing()

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CPACK_OUTPUT_FILE_PREFIX ${CMAKE_BINARY_DIR}/packages)

# Standard locations
#
set(SOURCE_UPLOAD_DIR ${CMAKE_BINARY_DIR}/upload)
set(SOURCE_DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/download)
set(SOURCE_INSTALL_DIR ${CMAKE_BINARY_DIR}/install)
set(SOURCE_SRC_DIR ${CMAKE_BINARY_DIR}/src)
set(TARGET_INSTALL_DIR ${CMAKE_BINARY_DIR}/build)

# Generate version information for package
#
execute_process(COMMAND git rev-list HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE VERSION_RESULT
    OUTPUT_VARIABLE VERSION_DATA
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

string(REPLACE "\n" ";" VERSION_DATA ${VERSION_DATA} )
list(LENGTH VERSION_DATA VERSION_REVISION)
list(GET VERSION_DATA 0 VERSION_HASH)
string(SUBSTRING ${VERSION_HASH} 0 8 VERSION_SHORTHASH)

# Ninja specifics
#
set(PACKAGE_VERSION 1.8.2)
set(PACKAGE_NAME ninja)
set(PACKAGE_VERSION_PACKAGE ${PACKAGE_VERSION}.${VERSION_REVISION}.r${VERSION_SHORTHASH})
set(PACKAGE_PUBLISH_URL https://h1grid.com:443/artifactory/cbt/devtools)
MESSAGE(STATUS "Building package version ninja-${PACKAGE_VERSION_PACKAGE}.*.tgz")

set(PACKAGE_SOURCE_SOURCE_URL_WINDOWS https://github.com/ninja-build/ninja/releases/download/v${PACKAGE_VERSION}/ninja-win.zip)
set(PACKAGE_SOURCE_SOURCE_URL_OSX https://github.com/ninja-build/ninja/releases/download/v${PACKAGE_VERSION}/ninja-mac.zip)
set(PACKAGE_SOURCE_SOURCE_URL_LINUX https://github.com/ninja-build/ninja/releases/download/v${PACKAGE_VERSION}/ninja-linux.zip)
set(PACKAGE_SOURCE_TARGET_FILE_WINDOWS ${SOURCE_DOWNLOAD_DIR}/ninja-win.zip)
set(PACKAGE_SOURCE_TARGET_FILE_OSX ${SOURCE_DOWNLOAD_DIR}/ninja-mac.zip)
set(PACKAGE_SOURCE_TARGET_FILE_LINUX ${SOURCE_DOWNLOAD_DIR}/ninja-linux.zip)

add_custom_target(download_ninja
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_DOWNLOAD_DIR}
    COMMAND ${CMAKE_COMMAND} -DSOURCE=${PACKAGE_SOURCE_SOURCE_URL_WINDOWS} -DTARGET=${PACKAGE_SOURCE_TARGET_FILE_WINDOWS} -P ${download_COMMAND}
    COMMAND ${CMAKE_COMMAND} -DSOURCE=${PACKAGE_SOURCE_SOURCE_URL_OSX} -DTARGET=${PACKAGE_SOURCE_TARGET_FILE_OSX} -P ${download_COMMAND}
    COMMAND ${CMAKE_COMMAND} -DSOURCE=${PACKAGE_SOURCE_SOURCE_URL_LINUX} -DTARGET=${PACKAGE_SOURCE_TARGET_FILE_LINUX} -P ${download_COMMAND}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_target(unpack_ninja
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_SRC_DIR}/windows/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/windows
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_SRC_DIR}/linux/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/linux
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_SRC_DIR}/osx/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/osx
    COMMAND python2 ${unzip_py_COMMAND} --file ${PACKAGE_SOURCE_TARGET_FILE_WINDOWS} --target ${SOURCE_SRC_DIR}/windows/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/windows
    COMMAND python2 ${unzip_py_COMMAND} --file ${PACKAGE_SOURCE_TARGET_FILE_LINUX} --target ${SOURCE_SRC_DIR}/linux/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/linux
    COMMAND python2 ${unzip_py_COMMAND} --file ${PACKAGE_SOURCE_TARGET_FILE_OSX} --target ${SOURCE_SRC_DIR}/osx/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/osx
    DEPENDS download_ninja
)

add_custom_target(package_ninja_windows
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_UPLOAD_DIR}
    COMMAND ${CMAKE_COMMAND} -E tar czf ${SOURCE_UPLOAD_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-windows.tgz ${PACKAGE_NAME}
    WORKING_DIRECTORY ${SOURCE_SRC_DIR}/windows
    DEPENDS unpack_ninja
)

add_custom_target(package_ninja_linux
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_UPLOAD_DIR}
    COMMAND ${CMAKE_COMMAND} -E tar czf ${SOURCE_UPLOAD_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-linux.tgz ${PACKAGE_NAME}
    WORKING_DIRECTORY ${SOURCE_SRC_DIR}/linux
    DEPENDS unpack_ninja
)

add_custom_target(package_ninja_osx
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_UPLOAD_DIR}
    COMMAND ${CMAKE_COMMAND} -E tar czf ${SOURCE_UPLOAD_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-osx.tgz ${PACKAGE_NAME}
    WORKING_DIRECTORY ${SOURCE_SRC_DIR}/osx
    DEPENDS unpack_ninja
)

add_custom_target(publish_ninja
    COMMAND ${python2_BIN} ${upload_py_COMMAND} --file ${SOURCE_UPLOAD_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-windows.tgz --url ${PACKAGE_PUBLISH_URL}/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-windows.tgz
    COMMAND ${python2_BIN} ${upload_py_COMMAND} --file ${SOURCE_UPLOAD_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-linux.tgz --url ${PACKAGE_PUBLISH_URL}/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-linux.tgz
    COMMAND ${python2_BIN} ${upload_py_COMMAND} --file ${SOURCE_UPLOAD_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-osx.tgz --url ${PACKAGE_PUBLISH_URL}/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-osx.tgz
    DEPENDS package_ninja_windows package_ninja_linux package_ninja_osx
)
