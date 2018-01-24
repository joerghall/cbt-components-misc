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

# Ninja specifics
#
set(PACKAGE_VERSION 1.2.2)
set(PACKAGE_NAME tclap)
set(PACKAGE_VERSION_PACKAGE ${PACKAGE_VERSION}.${VERSION_REVISION}.r${VERSION_SHORTHASH})
set(PACKAGE_PUBLISH_URL https://h1grid.com:443/artifactory/cbt/components)
MESSAGE(STATUS "Building package version ${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-noarch.tgz")

set(PACKAGE_SOURCE_SOURCE_URL https://sourceforge.net/projects/tclap/files/tclap-${PACKAGE_VERSION}.tar.gz)
set(PACKAGE_SOURCE_TARGET_FILE ${SOURCE_DOWNLOAD_DIR}/tclap-${PACKAGE_VERSION}.tar.gz)

add_custom_target(download_${PACKAGE_NAME}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_DOWNLOAD_DIR}
    COMMAND git clone https://git.code.sf.net/p/tclap/code tclap
    COMMAND ${CMAKE_COMMAND} -DSOURCE=${PACKAGE_SOURCE_SOURCE_URL} -DTARGET=${PACKAGE_SOURCE_TARGET_FILE} -P ${download_COMMAND}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_target(unpack_${PACKAGE_NAME}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_SRC_DIR}/windows/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/noarch
    COMMAND ${CMAKE_COMMAND} -P ${untar_COMMAND} --file ${PACKAGE_SOURCE_TARGET_FILE} --target ${SOURCE_SRC_DIR}/${PACKAGE_NAME}/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/noarch
    DEPENDS download_${PACKAGE_NAME}
)

add_custom_target(package_${PACKAGE_NAME}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SOURCE_UPLOAD_DIR}
    COMMAND ${CMAKE_COMMAND} -P ${untar_COMMAND} --source ${SOURCE_UPLOAD_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-noarch.tgz ${SOURCE_SRC_DIR}/${PACKAGE_NAME}/${PACKAGE_NAME}
    DEPENDS unpack_${PACKAGE_NAME}
)


add_custom_target(publish_${PACKAGE_NAME}
    COMMAND ${python2_BIN} ${upload_py_COMMAND} --file ${SOURCE_UPLOAD_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-noarch.tgz --url ${PACKAGE_PUBLISH_URL}/${PACKAGE_NAME}/${PACKAGE_VERSION_PACKAGE}/${PACKAGE_NAME}-${PACKAGE_VERSION_PACKAGE}-windows.tgz
    DEPENDS package_${PACKAGE_NAME}
)
