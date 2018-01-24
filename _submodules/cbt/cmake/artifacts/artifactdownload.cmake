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

# Primitive to download a artifact via http
#
function (artifact_download_http RESULT SOURCE TARGET)

    # Check if the target file exists and remove if found
    if (EXISTS ${TARGET})
        file(REMOVE ${TARGET})
        if (EXISTS ${TARGET})
            message(FATAL_ERROR "artifact_download_http: Failed to remove ${TARGET}")
        endif ()
    endif ()
    file(DOWNLOAD ${SOURCE} ${TARGET} SHOW_PROGRESS TLS_VERIFY off STATUS return_status)
    list(GET return_status 0 status_code)
    if(${status_code} EQUAL 0)
        message(STATUS "artifact_download_http: ${return_status} for URL ${SOURCE}")
    else()
        message(WARNING "artifact_download_http: ${return_status} for URL ${SOURCE}")
    endif()
    set(${RESULT} ${status_code} PARENT_SCOPE)

endfunction (artifact_download_http)

# Primitive to copy a artifact from a local folder
#
function (artifact_download_file RESULT SOURCE TARGET)

    # Check if the target file exists and remove if found
    if (EXISTS ${TARGET})
        file(REMOVE ${TARGET})
        if (EXISTS ${TARGET})
            message(FATAL_ERROR "artifact_download_file: Failed to remove ${TARGET}")
        endif ()
    endif ()

    get_filename_component(TARGET_PATH ${TARGET} DIRECTORY)
    file(COPY ${SOURCE} DESTINATION ${TARGET_PATH})
    set(${RESULT} 0 PARENT_SCOPE)

endfunction ()

# Download an artifact, supports tries over mutiple hosts
#
function (artifact_download SOURCE TARGET)

    if (${SOURCE} MATCHES "^http://.*" OR ${SOURCE} MATCHES "^https://.*")
        if ("${SOURCE}" MATCHES "{ARTIFACTORY}")
            # Try the various locations
            foreach (ARTIFACTORY ${ARTIFACTORIES})
                string(REPLACE "{ARTIFACTORY}" ${ARTIFACTORY} FINAL_SOURCE ${SOURCE})
                message("artifact_download - SOURCE: ${FINAL_SOURCE} TARGET: ${TARGET}")
                artifact_download_http(RESULT ${FINAL_SOURCE} ${TARGET})
                if (${RESULT} EQUAL 0)
                    return()
                endif ()
            endforeach ()
        else ()
            message("artifact_download - SOURCE: ${SOURCE} TARGET: ${TARGET}")
            artifact_download_http(RESULT ${SOURCE} ${TARGET})
            if(${RESULT} EQUAL 0)
                return()
            endif()
        endif ()
    elseif(EXISTS ${SOURCE})
        message(FATAL_ERROR "artifact_download_file not implemented")
    endif()

    message(FATAL_ERROR "Unable to download ${SOURCE} to ${TARGET}")

endfunction ()
