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

cmake_minimum_required(VERSION 3.20)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

include(FetchContent)
include(ExternalProject)
project(Arcadia-Dependencies)

include(${CMAKE_CURRENT_SOURCE_DIR}/zlib.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/libpng.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/freetype.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/openal.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/opengl.cmake)
