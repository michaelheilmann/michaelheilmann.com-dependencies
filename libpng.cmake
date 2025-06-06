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

set(target my-libpng)
DoBeginPackage(${target})

set(CMAKE_ARGS "")

list(APPEND CMAKE_ARGS "-DZLIB_ROOT=${CMAKE_CURRENT_BINARY_DIR}/my-zlib/pkg/$<LOWER_CASE:$<CONFIG>>")
list(APPEND CMAKE_ARGS "-DZLIB_USE_STATIC_LIBS=ON")
list(APPEND CMAKE_ARGS "-DZLIB_LIBRARY=${CMAKE_CURRENT_BINARY_DIR}/my-zlib/pkg/$<LOWER_CASE:$<CONFIG>>/lib/zlib.lib")
list(APPEND CMAKE_ARGS "-DZLIB_INCLUDE_DIRS=${CMAKE_CURRENT_BINARY_DIR}/my-zlib/pkg/$<LOWER_CASE:$<CONFIG>>/include")
list(APPEND CMAKE_ARGS "-DPNG_SHARED=OFF")
list(APPEND CMAKE_ARGS "-DPNG_TESTS=OFF") 
list(APPEND CMAKE_ARGS "-DCMAKE_POLICY_POLICY_DEFAULT_CMP0074=NEW")

ExternalProject_Add(${target}-external
                    DEPENDS my-zlib-CREATE-ZIP-ARCHIVE
                    GIT_REPOSITORY https://github.com/glennrp/libpng.git
                    GIT_SHALLOW TRUE
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/my-libpng
                    CMAKE_ARGS ${CMAKE_ARGS}
                    SOURCE_DIR ${${target}-SOURCE_DIR}
                    BINARY_DIR ${${target}-BUILD_DIR}
                    STAMP_DIR ${${target}-STAMP_DIR}
                    TMP_DIR ${${target}-TMP_DIR}
                    INSTALL_COMMAND ""
                    TEST_COMMAND "")

# We use the "touch" method to avoid issues with file modification timestamps causing an MSB8065 warning.
add_custom_command(OUTPUT ${${target}-PACKAGE_DIR}/.create-directories-stamp-${suffix}
                   DEPENDS ${target}-external
                   COMMAND ${CMAKE_COMMAND} -E make_directory ${${target}-PACKAGE_INCLUDES_DIR} ${${target}-PACKAGE_LIBRARIES_DIR}
                   COMMAND ${CMAKE_COMMAND} -E touch ${${target}-PACKAGE_DIR}/.create-directories-stamp-${suffix})

add_custom_command(OUTPUT ${${target}-PACKAGE_DIR}/.create-libraries-stamp-${suffix}
                   DEPENDS ${target}-CREATE-DIRECTORIES ${target}-external
                   COMMAND ${CMAKE_COMMAND} -E copy ${${target}-BUILD_DIR}/${configuration}/$<IF:$<CONFIG:Debug>,libpng16_staticd.lib,libpng16_static.lib>
                                                    ${${target}-PACKAGE_LIBRARIES_DIR}/libpng.lib
                   COMMAND ${CMAKE_COMMAND} -E touch ${${target}-PACKAGE_DIR}/.create-libraries-stamp-${suffix})

add_custom_command(OUTPUT ${${target}-PACKAGE_DIR}/.create-includes-stamp-${suffix}
                   DEPENDS ${target}-CREATE-DIRECTORIES ${target}-external
                   COMMAND ${CMAKE_COMMAND} -E copy ${${target}-SOURCE_DIR}/png.h
                                                    ${${target}-PACKAGE_INCLUDES_DIR}/png.h
                   COMMAND ${CMAKE_COMMAND} -E copy ${${target}-SOURCE_DIR}/pngconf.h
                                                    ${${target}-PACKAGE_INCLUDES_DIR}/pngconf.h
                   COMMAND ${CMAKE_COMMAND} -E copy ${${target}-BUILD_DIR}/pnglibconf.h
                                                    ${${target}-PACKAGE_INCLUDES_DIR}/pnglibconf.h
                   COMMAND ${CMAKE_COMMAND} -E touch ${${target}-PACKAGE_DIR}/.create-includes-stamp-${suffix})

DoEndPackage(${target})
