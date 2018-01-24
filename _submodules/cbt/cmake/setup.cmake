# MIT License
#
# Copyright (c) 2017 Joerg Hallmann
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
# https://github.com/joerghall/cbt
#
cmake_minimum_required(VERSION 3.0)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_LIST_DIR}/artifacts")
list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_LIST_DIR}/components")
list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_LIST_DIR}/toolsets")

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_LIST_DIR}")

#
get_filename_component(cbt_LOCATION ${CMAKE_CURRENT_LIST_DIR} DIRECTORY CACHE)

# CMake scripts
set(download_COMMAND ${cbt_LOCATION}/cmake/scripts/download-command.cmake)
set(untar_COMMAND ${cbt_LOCATION}/cmake/scripts/untar-command.cmake)
set(unzip_COMMAND ${cbt_LOCATION}/cmake/scripts/untar-command.cmake)

# Python scripts
set(upload_py_COMMAND ${cbt_LOCATION}/buildpy/upload-artifactory.py)
set(unzip_py_COMMAND ${cbt_LOCATION}/buildpy/unzip-archive.py)

get_filename_component(temp_file_path ${CMAKE_CURRENT_LIST_DIR}/.. REALPATH)
set(BUILD_TOOLS ${temp_file_path} CACHE PATH "Location of the buildtools" FORCE)

include(os)

if(BUILD_BITNESS)
else()
    set(BUILD_BITNESS x86_64 CACHE STRING "Bitness of the build" FORCE)
endif()

if (APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET 10.10)
    set(BUILD_PLATFORM "osx${CMAKE_OSX_DEPLOYMENT_TARGET}" CACHE STRING "Platform of the build" FORCE)
elseif (UNIX)
    set(BUILD_PLATFORM ${BUILD_OS}${BUILD_OS_VERSION} CACHE STRING "Platform of the build" FORCE)
endif ()

if (CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Multipe build configurations - IDE build")
else ()
    if (CMAKE_BUILD_TYPE)
        set(BUILD_TYPE debug CACHE STRING "Build type" FORCE)
    else ()
        set(BUILD_TYPE release CACHE STRING "Build type" FORCE)
    endif ()
endif ()

include(artifactdownload)
include(artifactcache)
setup_artifact_cache()

#if(BUILD_WINDOWS)
#    add_artifact("python2" "https://h1grid.com:443/artifactory/cbt/devtools/python/2.7.14/python2-2.7.14-windows-x64.tgz" ${ARTIFACT_TOOLSETS_CACHE} "python2/2.7.14/windows-x64" "python2-2.7.14-windows-x64.tgz")
#    add_artifact("ninja" "https://h1grid.com:443/artifactory/cbt/devtools/ninja/1.8.2/ninja-1.8.2-windows.tgz" ${ARTIFACT_TOOLSETS_CACHE} "ninja/1.8.2/windows" "ninja-1.8.2-windows.tgz")
#    add_artifact("pigz" "https://h1grid.com:443/artifactory/cbt/devtools/pigz/2.3.1/pigz-2.3.1-windows.tgz" ${ARTIFACT_TOOLSETS_CACHE} "pigz/2.3.1/windows" "pigz-2.3.1-windows.tgz")
#elseif(BUILD_OSX)
#    add_artifact("python2" "https://h1grid.com:443/artifactory/cbt/devtools/python/2.7.14/python-2.7.14-osx.tgz" ${ARTIFACT_TOOLSETS_CACHE} "python/2.7.14/osx" "python-2.7.14-osx.tgz")
#    add_artifact("ninja" "https://h1grid.com:443/artifactory/cbt/devtools/ninja/1.8.2/ninja-1.8.2-osx.tgz" ${ARTIFACT_TOOLSETS_CACHE} "ninja/1.8.2/osx" "ninja-1.8.2-osx.tgz")
#    add_artifact("pigz" "https://h1grid.com:443/artifactory/cbt/devtools/pigz/2.3.4/pigz-2.3.4-osx.tgz" ${ARTIFACT_TOOLSETS_CACHE} "pigz/2.3.4/osx" "pigz-2.3.4-osx.tgz")
#elseif(BUILD_LINUX)
#    add_artifact("python2" "https://h1grid.com:443/artifactory/cbt/devtools/python/2.7.14/python-2.7.14-linux.tgz" ${ARTIFACT_TOOLSETS_CACHE} "python/2.7.14/linux" "python-2.7.14-linux.tgz")
#    add_artifact("ninja" "https://h1grid.com:443/artifactory/cbt/devtools/ninja/1.8.2/ninja-1.8.2-linux.tgz" ${ARTIFACT_TOOLSETS_CACHE} "ninja/1.8.2/linux" "ninja-1.8.2-windows.tgz")
#    add_artifact("pigz" "https://h1grid.com:443/artifactory/cbt/devtools/pigz/2.3.1/pigz-2.3.4-linux.tgz" ${ARTIFACT_TOOLSETS_CACHE} "pigz/2.3.4/linux" "pigz-2.3.4-windows.tgz")
#endif()

#include(version)
#include(sourcemapprefix)
