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

# Determind a suitable location for cache
# 1) specify via cmake -DARTIFACTROOT=<value>
# 2) Specify as an evironment variable
# 3) Use predefined defaults based on OS type
function(setup_artifact_cache)

    # Setup the cache paths
    #
    if (DEFINED ENV{ARTIFACTROOT})
        set(ARTIFACTROOT $ENV{ARTIFACTROOT})
    elseif(ARTIFACTROOT)
        # Provided as variable externally
    else ()
        if(BUILD_WINDOWS)
            set(ARTIFACTROOT "$ENV{SystemDrive}/cbt-cache")
        elseif(BUILD_POSIX)
            set(ARTIFACTROOT "$ENV{HOME}/cbt-cache")
        else ()
            message(FATAL_ERROR "Unable to determinend an artifact cache location. Use ARTIFACTROOT variable/env variable.")
        endif ()
    endif ()

    set(ARTIFACT_COMPONENTS_CACHE ${ARTIFACTROOT}/components CACHE PATH "Components location")
    file(MAKE_DIRECTORY ${ARTIFACT_COMPONENTS_CACHE})

    set(ARTIFACT_TOOLSETS_CACHE ${ARTIFACTROOT}/toolsets CACHE PATH "Toolsets location")
    file(MAKE_DIRECTORY ${ARTIFACT_TOOLSETS_CACHE})

endfunction()

# Add artifact
#
function(add_artifact PACKAGE SOURCEURL TARGETPATH TARGETRELATIVEPATH TARGETFILENAME)

    # Check if the artifact is ready
    artifact_ready(is_ready ${TARGETPATH}/${TARGETRELATIVEPATH})
    if (is_ready EQUAL 0)

        artifact_download(${SOURCEURL} ${TARGETPATH}/${TARGETFILENAME})

        if (EXISTS ${TARGETPATH}/${TARGETFILENAME})

            exec_program(${CMAKE_COMMAND} ${TARGETPATH} ARGS -E tar zxf ${TARGETFILENAME} OUTPUT_VARIABLE output RETURN_VALUE result)

            file(REMOVE ${TARGETPATH}/${TARGETFILENAME})

            if (NOT result EQUAL 0)
                if (EXISTS ${TARGETPATH}/${TARGETRELATIVEPATH})
                    file(REMOVE ${TARGETPATH}/${TARGETRELATIVEPATH})
                endif ()
                message(FATAL_ERROR "Failed to unpack ${TARGETPATH}/${TARGETRELATIVEPATH} with exitcode=${result} output:\n${output}")
            elseif(NOT EXISTS ${TARGETPATH}/${TARGETRELATIVEPATH})
                message(FATAL_ERROR "Unable to find ${PACKAGE} with requested name ${TARGETFILENAME}  - ${TARGETPATH}/${TARGETRELATIVEPATH}")
            else ()
                artifact_done(${TARGETPATH}/${TARGETRELATIVEPATH})
            endif()
        endif ()
    else ()
        message(STATUS "Found package ${PACKAGE} in ${TARGETPATH}/${TARGETRELATIVEPATH}")
    endif ()

    if (NOT "${${PACKAGE}_LOCATION}" STREQUAL "${TARGETPATH}/${TARGETRELATIVEPATH}")
        set(${PACKAGE}_LOCATION ${TARGETPATH}/${TARGETRELATIVEPATH} CACHE PATH "Location of the package ${PACKAGE}" FORCE)
        artifact_used(${TARGETPATH}/${TARGETRELATIVEPATH})
    endif ()

endfunction(add_artifact)

# Record the usage of an artifact
#
function(artifact_used artifact_path)
    string(TIMESTAMP ts "%Y-%m-%d %H:%M:%S")
    file(APPEND ${artifact_path}/cbt_report.csv "${ts}\n")
endfunction()

# Record artifact
#
function(artifact_done artifact_path)
    if (NOT EXISTS ${artifact_path}/cbt_report.csv)
        file(WRITE ${artifact_path}/cbt_report.csv "timestamp\n")
    endif ()
    artifact_used(${artifact_path})
    message(STATUS "Created artifact ${artifact_path}")
endfunction()

# Check if the artifact was used
#
function(artifact_ready OUTPUT artifact_path)
    if (EXISTS ${artifact_path}/cbt_report.csv)
        set(${OUTPUT} 1 PARENT_SCOPE)
    else ()
        set(${OUTPUT} 0 PARENT_SCOPE)
        if (EXISTS ${artifact_path})
            message(STATUS "Removing bad artifact ${artifact_path}")
            file(REMOVE ${artifact_path})
        endif ()
    endif ()
endfunction()
