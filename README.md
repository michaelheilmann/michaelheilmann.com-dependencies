# michaelheilmann.com-dependencies
Allows for prebuilding the depdendencies for WINDOWS build of [michaelheilmann.com](https://michaelheilmann.com).

### Repository Contents
This repository contains CMake build files to download and build the dependencies for WINDOWS build of [michaelheilmann.com](https://michaelheilmann.com).

## Requirements
This project requires GIT and KitWare's CMake to build.

The project requires Git and CMake to build to be in your path as well as the reachability of the following Git repositories:
- [freetype](https://gitlab.freedesktop.org/freetype/freetype.git)
- [libpng](https://github.com/glennrp/libpng.git)
- [zlib](https://github.com/madler/zlib.git)
- [openal-soft](https://github.com/kcat/openal-soft)
- [opengl](https://registry.khronos.org/OpenGL/index_gl.php)

### Building under Windows / Visual Studio
- Checkout the repository
  [https://github.com/michaelheilmann/michaelheilmann-dependencies.com](https://github.com/michaelheilmann/michaelheilmann-dependencies.com) to a directory on your machine.
- Create a directory called the build directory. That directory must not be the source directory or a subdirectory of the source directory.
- Invoke `cmake <source directory>` where `<source directory>` is the path to the source directory.
- Open the `Arcadia-Dependencies.sln` solution file.

Remarks: This will build the target architecture that is the default of your machine.
To generate the build files for the target architecture x86, change the command to `cmake -A Win32 <source directory>`.
To generate the build files for the target architecture x64, change the command to `cmake -A x64 <source directory>`.

### Building additional tools under Windows
This section contains manuals how to build libraries which are not integrated into the dependencies build.
The manuals explain how to build them manually.

#### libopenssl
- Install [Strawberry Perl](https://strawberryperl.com)
- Install [Netwide Assembler](https://www.nasm.us). Do *not* use the portable versions.
- Ensure "Desktop Development With C++ Workload" is installed (for vcvarsall.bat).
- Download libopenssl-3.5.4 and unpack to directory C:\build\libopenssl-3.5.4.
- Open the `Developer Command Prompt` and enter

```
nmake clean
"C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
perl Configure VC-WIN64A --prefix=C:\Users\Anwender\Downloads\build\x64 --openssldir=C:\Users\Anwender\Downloads\openssl-master
nmake
nmake install_sw
```

```
nmake clean
"C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64_x86
perl Configure VC-WIN32 --prefix=C:\Users\Anwender\Downloads\build\x86 --openssldir=C:\Users\Anwender\Downloads\openssl-master
nmake
nmake install_sw
```

### Build status
- Windows Main [![Build status](https://ci.appveyor.com/api/projects/status/ap4tbo0e8554fdk4/branch/main?svg=true)](https://ci.appveyor.com/project/michaelheilmann-com/michaelheilmann-com-dependencies)
