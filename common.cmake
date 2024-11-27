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

macro(DoBeginPackage target)
  set(configuration $<LOWER_CASE:$<CONFIG>>)


  set(${target}-SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/${target}/src")
  set(${target}-BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/${target}/bld")
  set(${target}-PACKAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/${target}/pkg")
  set(${target}-STAMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/${target}/stmp")
  set(${target}-TMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/${target}/tmp")

  set(${target}-PACKAGE_INCLUDES_DIR ${${target}-PACKAGE_DIR}/${configuration}/include)
  set(${target}-PACKAGE_LIBRARIES_DIR ${${target}-PACKAGE_DIR}/${configuration}/lib)

  #  Custom target for creating the directories.
  add_custom_target(${target}-CREATE-DIRECTORIES DEPENDS ${${target}-PACKAGE_DIR}/.create-directories-stamp-${configuration})

  # Custom target for creating the library files.
  add_custom_target(${target}-CREATE-LIBRARIES DEPENDS ${${target}-PACKAGE_DIR}/.create-libraries-stamp-${configuration})

  # Custom target for creating the include files.
  add_custom_target(${target}-CREATE-INCLUDES DEPENDS ${${target}-PACKAGE_DIR}/.create-directories-stamp-${configuration} ${${target}-PACKAGE_DIR}/.create-includes-stamp-${configuration})

endmacro()

macro(DoEndPackage target)

  # "*-package" project.
  add_custom_target(${target}-package ALL DEPENDS ${target}-CREATE-LIBRARIES ${target}-CREATE-INCLUDES)

  # zip archive creation
  add_custom_command(OUTPUT ${${target}-PACKAGE_DIR}/.create-zip-archive-stamp-${configuration}
                     DEPENDS ${target}-CREATE-LIBRARIES ${target}-CREATE-INCLUDES
                     WORKING_DIRECTORY "${${target}-PACKAGE_DIR}"
                     COMMAND ${CMAKE_COMMAND} -E tar cf "${${target}-PACKAGE_DIR}/${target}-${configuration}.zip" --format=zip "${${target}-PACKAGE_DIR}/${configuration}"
                     COMMAND ${CMAKE_COMMAND} -E touch ${${target}-PACKAGE_DIR}/.create-zip-archive-stamp-${configuration})

  # "*-CREATE-ZIP-ARCHIVE" project.
  add_custom_target(${target}-CREATE-ZIP-ARCHIVE DEPENDS ${${target}-PACKAGE_DIR}/.create-zip-archive-stamp-${configuration})

endmacro()