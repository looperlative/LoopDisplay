#!/bin/zsh

# Increment BUILD_NUMBER before each TestFlight upload.
BUILD_NUMBER=1

$HOME/Qt/Tools/CMake/CMake.app/Contents/bin/cmake -B build-ios \
    -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=$HOME/Qt/6.11.0/ios/lib/cmake/Qt6/qt.toolchain.cmake \
    -DQT_HOST_PATH=$HOME/Qt/6.11.0/macos \
    -DBUILD_NUMBER=$BUILD_NUMBER
