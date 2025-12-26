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

# Last modified: 2026-01-01

###########################################################################################################################

#$prefix="${env:Temp}\arcadia"
#Write-Host "prefix := ${prefix}"

function Invoke-Call-1 {
    $exe = $args[0]
    $args = @($args[1..$args.Length])

    Write-Host 'Command: ', $exe, $args

    # Disable ErrorActionPreference temporarily https://stackoverflow.com/questions/10666101/lastexitcode-0-but-false-in-powershell-redirecting-stderr-to-stdout-gives
    $SaveErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    # Refer to https://stackoverflow.com/questions/8097354/how-do-i-capture-the-output-into-a-variable-from-an-external-process-in-powershe
    $Output = & $exe $args 2>&1 | ForEach-Object {
        if($_ -Is [System.Management.Automation.ErrorRecord])
        {
            $_.Exception.Message | Write-Host
            $_.Exception.Message
        }
        else
        {
            $_ | Write-Host
            $_
        }
    }

    $ExitCode = $LASTEXITCODE

    # Reset ErrorActionPreference
    $ErrorActionPreference = $SaveErrorActionPreference

    return $ExitCode, $Output
}

function Invoke-Call {
    $ExitCode, $Output = Invoke-Call-1 @args
    $Success = ($ExitCode -eq 0)
    if (-Not $Success)
    {
        Write-Error "'$Args' failed with exit code $ExitCode"
        exit $ExitCode
    }
    return $Output
}

function Invoke-GIT {
    param (
        [string]$Arguments
    )
  if ($Arguments) {
    $proc = Start-Process git -PassThru -NoNewWindow -ArgumentList $Arguments
  } else {
    $proc = Start-Process git -PassThru -NoNewWindow    
  }
  $proc | Wait-Process
  #$proc.ExitCode
}

Write-Host "creating ./.dependencies"
$sink = mkdir -Force ./.dependencies

Write-Host "creating ./.download"
$sink = mkdir -Force ./.download

Write-Host "creating ./.unpack"
$sink = mkdir -Force ./.unpack

Write-Host "creating ./.build"
$sink = mkdir -Force ./.build  

if (1) {
  Write-Host "build started libressl"
  if (-not(Test-Path -Path ./.unpack/libressl -PathType Container)) {
    Write-Host "  downloading libressl"    
    Invoke-WebRequest -Uri https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-4.2.1.tar.gz -OutFile ./.download/libressl-4.2.1.tar.gz
    Write-Host "  unpacking libressl"    
    tar -xf ./.download/libressl-4.2.1.tar.gz -C ./.unpack
    mv ./.unpack/libressl-4.2.1 ./.unpack/libressl
    Write-Host "  creating build directory"    
    $sink = mkdir -Force ./.build/libressl
  }
  
  $cmd = "cmake", "-S ./../../.unpack/libressl", "-B ."

  cd ./.build/libressl
  
  Invoke-Call @cmd

  Invoke-Call cmake --build . --config Debug
  Invoke-Call cmake --install . --config Debug --prefix './../../.dependencies/debug/libressl'

  Invoke-Call cmake --build . --config Release
  Invoke-Call cmake --install . --config Release --prefix './../../.dependencies/release/libressl'

  Invoke-Call cmake --build . --config MinSizeRel
  Invoke-Call cmake --install . --config MinSizeRel --prefix './../../.dependencies/minsizerel/libressl'

  Invoke-Call cmake --build . --config RelWithDebInfo
  Invoke-Call cmake --install . --config RelWithDebInfo --prefix './../../.dependencies/relwithdebinfo/libressl'

  cd ..
  cd ..

}

###########################################################################################################################

if (1) {
  Write-Host "build started zlib"
  if (-not(Test-Path -Path ./.unpack/zlib -PathType Container)) {
    cd ./.unpack
    Invoke-GIT -Arguments "clone https://github.com/madler/zlib.git"   
    cd ..
    $sink = mkdir -Force ./.build/zlib
  }

  cd ./.build/zlib

  $cmd = "cmake", "-S ./../../.unpack/zlib", "-B ." 
  Invoke-Call @cmd

  Invoke-Call cmake --build . --config Debug
  Invoke-Call cmake --install . --config Debug --prefix './../../.dependencies/debug/zlib'

  Invoke-Call cmake --build . --config Release
  Invoke-Call cmake --install . --config Release --prefix './../../.dependencies/release/zlib'

  Invoke-Call cmake --build . --config MinSizeRel
  Invoke-Call cmake --install . --config MinSizeRel --prefix './../../.dependencies/minsizerel/zlib'

  Invoke-Call cmake --build . --config RelWithDebInfo
  Invoke-Call cmake --install . --config RelWithDebInfo --prefix './../../.dependencies/relwithdebinfo/zlib'

  cd ..
  cd ..

}

###########################################################################################################################

if (1) {
  Write-Host "build started libpng"
  if (-not(Test-Path -Path ./.unpack/libpng -PathType Container)) {
    cd ./.unpack
    Invoke-GIT -Arguments "clone https://github.com/glennrp/libpng.git"   
    cd ..
    $sink = mkdir -Force ./.build/libpng
  }

  $commonCmd = "-DZLIB_USE_STATIC_LIBS=ON -DPNG_SHARED=OFF -DPNG_TESTS=OFF";

  cd ./.build/libpng

  $cmd = "cmake", "-DZLIB_ROOT=$pwd\..\..\.dependencies\debug\zlib", "$commonCmd", "-S ./../../.unpack/libpng", "-B ."
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config Debug
  Invoke-Call cmake --install . --config Debug --prefix './../../.dependencies/debug/libpng'

  $cmd = "cmake", "-DZLIB_ROOT=./../../.dependencies/release/zlib", "$commonCmd", "-S ./../../.unpack/libpng", "-B ."
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config Release
  Invoke-Call cmake --install . --config Release --prefix './../../.dependencies/release/libpng'

  $cmd = "cmake", "-DZLIB_ROOT=./../../.dependencies/minsizerel/zlib", "$commonCmd", "-S ./../../.unpack/libpng", "-B ."
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config MinSizeRel
  Invoke-Call cmake --install . --config MinSizeRel --prefix './../../.dependencies/minsizerel/libpng'

  $cmd = "cmake", "-DZLIB_ROOT=./../../.dependencies/relwithdebinfo/zlib", "$commonCmd", "-S ./../../.unpack/libpng", "-B ." 
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config RelWithDebInfo
  Invoke-Call cmake --install . --config RelWithDebInfo --prefix './../../.dependencies/relwithdebinfo/libpng'

  cd ..
  cd ..

}

###########################################################################################################################

if (1) {
  Write-Host "build started freetype"
  if (-not(Test-Path -Path ./.unpack/freetype -PathType Container)) {
    cd ./.unpack
    Invoke-GIT -Arguments "clone https://gitlab.freedesktop.org/freetype/freetype.git"   
    cd ..
    mkdir -Force ./.build/freetype
  }

  $commonCmd = "-DBUILD_SHARED_LIBS=OFF", "-S ./../../.unpack/freetype", "-B ."

  cd ./.build/freetype

  $cmd = "cmake", "-DPNG_PNG_INCLUDE_DIR=./../../.dependencies/debug/libpng/include", "-DPNG_LIBRARY=./../../.dependencies/debug/libpng/lib/libpng18_staticd.lib"
  $cmd += "-DZLIB_INCLUDE_DIR=./../../.dependencies/debug/zlib/include", "-DZLIB_LIBRARY=./../../.dependencies/debug/zlib/zsd.lib"
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config Debug
  Invoke-Call cmake --install . --config Debug --prefix './../../.dependencies/debug/freetype'

  $cmd = "cmake", "-DPNG_PNG_INCLUDE_DIR=./../../.dependencies/release/libpng/include", "-DPNG_LIBRARY=./../../.dependencies/release/libpng/lib/libpng18_static.lib"
  $cmd += "-DZLIB_INCLUDE_DIR=./../../.dependencies/release/zlib/include", "-DZLIB_LIBRARY=./../../.dependencies/release/zlib/zs.lib"
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config Release
  Invoke-Call cmake --install . --config Release --prefix './../../.dependencies/release/freetype'

  $cmd = "cmake", "-DPNG_PNG_INCLUDE_DIR=./../../.dependencies/minsizerel/libpng/include", "-DPNG_LIBRARY=./../../.dependencies/minsizerel/libpng/lib/libpng18_static.lib"
  $cmd += "-DZLIB_INCLUDE_DIR=./../../.dependencies/minsizerel/zlib/include", "-DZLIB_LIBRARY=./../../.dependencies/minsizerel/zlib/zs.lib"
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config MinSizeRel
  Invoke-Call cmake --install . --config MinSizeRel --prefix './../../.dependencies/minsizerel/freetype'

  $cmd = "cmake", "-DPNG_PNG_INCLUDE_DIR=./../../.dependencies/relwithdebinfo/libpng/include", "-DPNG_LIBRARY=./../../.dependencies/relwithdebinfo/libpng/lib/libpng18_static.lib"
  $cmd += "-DZLIB_INCLUDE_DIR=./../../.dependencies/relwithdebinfo/zlib/include", "-DZLIB_LIBRARY=./../../.dependencies/relwithdebinfo/zlib/zs.lib"
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config RelWithDebInfo
  Invoke-Call cmake --install . --config RelWithDebInfo --prefix './../../.dependencies/relwithdebinfo/freetype'

  cd ..
  cd ..

}

###########################################################################################################################

if (1) {

  if (-not(Test-Path -Path ./.unpack/ogg -PathType Container)) {
    cd ./.unpack
    Invoke-GIT -Arguments "clone https://gitlab.xiph.org/xiph/ogg.git"   
    cd ..
    mkdir -Force ./.build/ogg
  }

  cd ./.build/ogg
  
  $commonCmd = @('-DBUILD_SHARED_LIBS=OFF'
                 , '-DINSTALL_DOCS=OFF'
                 , '-S ./../../.unpack/ogg'
                 , '-B .');

  $cmd = ,"cmake"
  $cmd += $commonCmd 
  Invoke-Call @cmd

  Invoke-Call cmake --build . --config Debug
  Invoke-Call cmake --install . --config Debug --prefix './../../.dependencies/debug/ogg'

  Invoke-Call cmake --build . --config Release
  Invoke-Call cmake --install . --config Release --prefix './../../.dependencies/release/ogg'

  Invoke-Call cmake --build . --config MinSizeRel
  Invoke-Call cmake --install . --config MinSizeRel --prefix './../../.dependencies/minsizerel/ogg'

  Invoke-Call cmake --build . --config RelWithDebInfo
  Invoke-Call cmake --install . --config RelWithDebInfo --prefix './../../.dependencies/relwithdebinfo/ogg'

  cd ..
  cd ..

}

###########################################################################################################################

if (1) {

  if (-not(Test-Path -Path ./.unpack/flac -PathType Container)) {
    cd ./.unpack
    Invoke-GIT -Arguments "clone https://github.com/xiph/flac.git"   
    cd ..
    mkdir -Force ./.build/flac
  }
  
  $commonCmd = @('-DBUILD_CXXLIBS=OFF' 
                 , '-DBUILD_DOCS=OFF'
                 , '-DBUILD_SHARED_LIBS=OFF'
                 , '-DBUILD_PROGRAMS=OFF'
                 , '-DBUILD_EXAMPLES=OFF'
                 , '-DINSTALL_MANPAGES=OFF'
                 , '-S ./../../.unpack/flac'
                 , '-B .')
             ;

  cd ./.build/flac

  $cmd = "cmake" `
       , "-D_OGG_INCLUDE_DIRS=./../../.dependencies/debug/ogg/include" `
       , "-D_OGG_LIBRARY_DIRS=./../../.dependencies/debug/ogg/lib" `
       ;
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config Debug
  Invoke-Call cmake --install . --config Debug --prefix './../../.dependencies/debug/flac'

  $cmd = "cmake" `
       , "-D_OGG_INCLUDE_DIRS=./../../.dependencies/release/ogg/include" `
       , "-D_OGG_LIBRARY_DIRS=./../../.dependencies/release/ogg/lib" `
       ;
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config Release
  Invoke-Call cmake --install . --config Release --prefix './../../.dependencies/release/flac'

  $cmd = "cmake" `
       , "-D_OGG_INCLUDE_DIRS=./../../.dependencies/minsizerel/ogg/include" `
       , "-D_OGG_LIBRARY_DIRS=./../../.dependencies/minsizerel/ogg/lib" `
       ;
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config MinSizeRel
  Invoke-Call cmake --install . --config MinSizeRel --prefix './../../.dependencies/minsizerel/flac'

  $cmd = "cmake" `
       , "-D_OGG_INCLUDE_DIRS=./../../.dependencies/relwithdebinfo/ogg/include" `
       , "-D_OGG_LIBRARY_DIRS=./../../.dependencies/relwithdebinfo/ogg/lib" `
       ;
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config RelWithDebInfo
  Invoke-Call cmake --install . --config RelWithDebInfo --prefix './../../.dependencies/relwithdebinfo/flac'

  cd ..
  cd ..

}

###########################################################################################################################

if (1) {

  if (-not(Test-Path -Path ./.unpack/openal-soft -PathType Container)) {
    cd ./.unpack
    Invoke-GIT -Arguments "clone --branch 1.24.1 https://github.com/kcat/openal-soft"   
    cd ..
    mkdir -Force ./.build/openal-soft
  }

  $commonCmd = @('-DLIBTYPE=STATIC'
                ,'-DALSOFT_UTILS=OFF'
                ,'-DALSOFT_TESTS=OFF'
                ,'-DALSOFT_EXAMPLES=OFF'
                ,'-S ./../../.unpack/openal-soft'
                '-B .')
             ;

  cd ./.build/openal-soft

  $cmd = ,"cmake"
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config Debug
  Invoke-Call cmake --install . --config Debug --prefix './../../.dependencies/debug/openal-soft'

  $cmd = ,"cmake"
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config Release
  Invoke-Call cmake --install . --config Release --prefix './../../.dependencies/release/openal-soft'

  $cmd = ,"cmake"
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config MinSizeRel
  Invoke-Call cmake --install . --config MinSizeRel --prefix './../../.dependencies/minsizerel/openal-soft'

  $cmd = ,"cmake"
  $cmd += $commonCmd
  Invoke-Call @cmd
  Invoke-Call cmake --build . --config RelWithDebInfo
  Invoke-Call cmake --install . --config RelWithDebInfo --prefix './../../.dependencies/relwithdebinfo/openal-soft'

  cd ..
  cd ..

}

###########################################################################################################################

if (1) {

  if (-not(Test-Path -Path ./.build/opengl -PathType Container)) {
    cd ./.unpack
    tar -xf ./../opengl.zip
    cd ..
    mkdir -Force ./.build/opengl  
  }

  cd ./.build/opengl
  Copy-item -Force -Recurse -Verbose ./../../.unpack/opengl/* -Destination .

  mkdir -Force ./../../.dependencies/debug/opengl
  Copy-item -Force -Recurse -Verbose ./* -Destination ./../../.dependencies/debug/opengl
  
  mkdir -Force ./../../.dependencies/release/opengl
  Copy-item -Force -Recurse -Verbose ./* -Destination ./../../.dependencies/release/opengl
  
  mkdir -Force ./../../.dependencies/minsizerel/opengl
  Copy-item -Force -Recurse -Verbose ./* -Destination ./../../.dependencies/minsizerel/opengl
  
  mkdir -Force ./../../.dependencies/relwithdebinfo/opengl
  Copy-item -Force -Recurse -Verbose ./* -Destination ./../../.dependencies/relwithdebinfo/opengl
  
  cd ..
  cd ..

}

###########################################################################################################################
