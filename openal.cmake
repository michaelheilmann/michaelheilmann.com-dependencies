# The author of this software is Michael Heilmann (contact@michaelheilmann.com).
#
# Copyright(c) 2024 Michael Heilmann (contact@michaelheilmann.com).
#
# Permission to use, copy, modify, and distribute this software for any
# purpose without fee is hereby granted, provided that this entire notice
# is included in all copies of any software which is or includes a copy
# or modification of this software and in all copies of the supporting
# documentation for such software.
#
# THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY.IN PARTICULAR, NEITHER THE AUTHOR NOR LUCENT MAKES ANY
# REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY
# OF THIS SOFTWARE OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.

# Last modified: 2024-12-01

cmake_minimum_required(VERSION 3.29)

include(${CMAKE_CURRENT_SOURCE_DIR}/common.cmake)

set(target my-openal)
DoBeginPackage(my-openal)

set(CMAKE_ARGS "")

list(APPEND CMAKE_ARGS "-DLIBTYPE=STATIC")

ExternalProject_Add(${target}-external
                    GIT_REPOSITORY https://github.com/kcat/openal-soft
                    GIT_TAG 1.24.1
                    GIT_SHALLOW TRUE
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/my-openal
                    CMAKE_ARGS ${CMAKE_ARGS}
                    SOURCE_DIR ${${target}-SOURCE_DIR}
                    BINARY_DIR ${${target}-BUILD_DIR}
                    STAMP_DIR ${${target}-STAMP_DIR}
                    TMP_DIR ${${target}-TMP_DIR}
                    INSTALL_COMMAND ""
                    TEST_COMMAND "")

# We use the "touch" method to avoid issues with file modification timestamps causing an MSB8065 warning.
add_custom_command(OUTPUT ${${target}-PACKAGE_DIR}/.create-directories-stamp-${configuration}
                   DEPENDS ${target}-external
                   COMMAND ${CMAKE_COMMAND} -E make_directory ${${target}-PACKAGE_INCLUDES_DIR} ${${target}-PACKAGE_LIBRARIES_DIR}
                   COMMAND ${CMAKE_COMMAND} -E touch ${${target}-PACKAGE_DIR}/.create-directories-stamp-${configuration})

add_custom_command(OUTPUT ${${target}-PACKAGE_DIR}/.create-libraries-stamp-${configuration}
                   DEPENDS ${target}-CREATE-DIRECTORIES ${target}-external
                   COMMAND ${CMAKE_COMMAND} -E copy ${${target}-BUILD_DIR}/${configuration}/$<IF:$<CONFIG:Debug>,OpenAL32.lib,OpenAL32.lib>
                                                    ${${target}-PACKAGE_LIBRARIES_DIR}/OpenAL32.lib
                   COMMAND ${CMAKE_COMMAND} -E touch ${${target}-PACKAGE_DIR}/.create-libraries-stamp-${configuration})

# We have the list of files to copy.
set(NAMES "")
list(APPEND NAMES AL/al.h AL/alc.h AL/alext.h AL/efx.h)
set(SOURCE_NAMES ${NAMES})
list(TRANSFORM SOURCE_NAMES PREPEND ${${target}-SOURCE_DIR}/include/)
set(TARGET_NAMES ${NAMES})
list(TRANSFORM TARGET_NAMES PREPEND ${${target}-PACKAGE_INCLUDES_DIR}/)

foreach (x y IN ZIP_LISTS SOURCE_NAMES TARGET_NAMES)
  get_filename_component(yd ${y} PATH)
  add_custom_command(TARGET ${target}-CREATE-INCLUDES PRE_BUILD
                     DEPENDS ${target}-CREATE-DIRECTORIES
                     COMMAND ${CMAKE_COMMAND} -E echo "creating ${yd}"
                     COMMAND ${CMAKE_COMMAND} -E make_directory ${yd})
  add_custom_command(TARGET ${target}-CREATE-INCLUDES PRE_BUILD
                     DEPENDS ${yd} ${target}-CREATE-DIRECTORIES
                     COMMAND ${CMAKE_COMMAND} -E echo "copying ${x} to ${y}"
                     COMMAND ${CMAKE_COMMAND} -E copy "${x}" "${y}")
endforeach()

DoEndPackage(my-openal)