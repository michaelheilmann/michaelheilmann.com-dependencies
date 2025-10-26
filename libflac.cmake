# The author of this software is Michael Heilmann (contact@michaelheilmann.com).
#
# Copyright(c) 2024-2025 Michael Heilmann (contact@michaelheilmann.com).
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

set(target my-libflac)
DoBeginPackage(${target})

set(CMAKE_ARGS "")

list(APPEND CMAKE_ARGS "-DBUILD_CXXLIBS=OFF")
list(APPEND CMAKE_ARGS "-DINSTALL_MANPAGES=OFF")
list(APPEND CMAKE_ARGS "-D_OGG_INCLUDE_DIRS=${CMAKE_CURRENT_BINARY_DIR}/my-ogg/pkg/$<LOWER_CASE:$<CONFIG>>/include")
list(APPEND CMAKE_ARGS "-D_OGG_LIBRARY_DIRS=${CMAKE_CURRENT_BINARY_DIR}/my-ogg/pkg/$<LOWER_CASE:$<CONFIG>>/lib")

ExternalProject_Add(${target}-external
                    DEPENDS my-ogg-CREATE-ZIP-ARCHIVE
                    GIT_REPOSITORY https://github.com/xiph/flac.git
                    GIT_SHALLOW TRUE
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/my-libflac
                    CMAKE_ARGS ${CMAKE_ARGS}
                    SOURCE_DIR ${${target}-SOURCE_DIR}
                    BINARY_DIR ${${target}-BUILD_DIR}
                    STAMP_DIR ${${target}-STAMP_DIR}
                    TMP_DIR ${${target}-TMP_DIR}
                    INSTALL_COMMAND ""
                    TEST_COMMAND "")

# We use the "touch" method to avoid issues with file modification timestamps causing an MSB8065 warning.
add_custom_command(OUTPUT ${${target}-PACKAGE_DIR}/.create-directories-stamp-${suffix}
                   COMMAND ${CMAKE_COMMAND} -E make_directory ${${target}-PACKAGE_INCLUDES_DIR}/FLAC ${${target}-PACKAGE_LIBRARIES_DIR}
                   COMMAND ${CMAKE_COMMAND} -E touch ${${target}-PACKAGE_DIR}/.create-directories-stamp-${suffix})

set(headers "all.h" "assert.h" "callback.h" "export.h" "format.h" "metadata.h" "ordinals.h" "stream_decoder.h" "stream_encoder.h")

add_custom_command(OUTPUT ${${target}-PACKAGE_DIR}/.create-libraries-stamp-${suffix}
                   DEPENDS ${target}-CREATE-DIRECTORIES ${target}-external
                   COMMAND ${CMAKE_COMMAND} -E copy ${${target}-BUILD_DIR}/src/libFLAC/${configuration}/$<IF:$<CONFIG:Debug>,FLAC.lib,FLAC.lib>
                                                    ${${target}-PACKAGE_LIBRARIES_DIR}/FLAC.lib
                   COMMAND ${CMAKE_COMMAND} -E touch ${${target}-PACKAGE_DIR}/.create-libraries-stamp-${suffix})

foreach(header ${headers})
  message(STATUS "copying header ${header}")
  add_custom_command(OUTPUT ${${target}-PACKAGE_INCLUDES_DIR}/FLAC/${header}
                     DEPENDS ${target}-CREATE-DIRECTORIES ${target}-external
                     COMMAND ${CMAKE_COMMAND} -E copy ${${target}-SOURCE_DIR}/include/FLAC/${header} ${${target}-PACKAGE_INCLUDES_DIR}/FLAC/${header})
endforeach()

list(TRANSFORM headers PREPEND ${${target}-PACKAGE_INCLUDES_DIR}/FLAC/)
add_custom_command(OUTPUT ${${target}-PACKAGE_DIR}/.create-includes-stamp-${suffix}
                   DEPENDS ${headers}
                   COMMAND ${CMAKE_COMMAND} -E touch ${${target}-PACKAGE_DIR}/.create-includes-stamp-${suffix})

DoEndPackage(${target})
