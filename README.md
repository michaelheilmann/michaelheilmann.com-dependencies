# michaelheilmann.com-dependencies
Allows for prebuilding the depdendencies for WINDOWS build of [michaelheilmann.com](https://michaelheilmann.com).

### Repository Contents
This repository contains CMake build files to download and build the dependencies for WINDOWS build of software found on [michaelheilmann.com](https://michaelheilmann.com).

## Requirements
This project requires GIT and KitWare's CMake to build.

The project requires Git and CMake to build to be in your path as well as the reachability of the following Git repositories/websites:
- [freetype](https://gitlab.freedesktop.org/freetype/freetype.git)
- [libressl](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-4.2.1.tar.gz)
- [libpng](https://github.com/glennrp/libpng.git)
- [zlib](https://github.com/madler/zlib.git)
- [openal-soft](https://github.com/kcat/openal-soft)
- [opengl](https://registry.khronos.org/OpenGL/index_gl.php)

### Building under Windows / Visual Studio
- Checkout the repository
  [https://github.com/michaelheilmann/michaelheilmann.com-dependencies](https://github.com/michaelheilmann/michaelheilmann.com-dependencies) to a directory on your machine.
- Enter that directory and execute the powershell script `build.ps`.
- The prebuilt dependencies should be located in the folder `.depenendencies` in the directory you checked out the repository to.

### Building additional tools under Windows
This section contains manuals how to build libraries which are not integrated into the dependencies build.
The manuals explain how to build them manually.

### Build status
- Windows Main [![Build status](https://ci.appveyor.com/api/projects/status/ap4tbo0e8554fdk4/branch/main?svg=true)](https://ci.appveyor.com/project/michaelheilmann-com/michaelheilmann-com-dependencies)
