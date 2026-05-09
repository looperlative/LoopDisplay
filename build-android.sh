#! /usr/bin/bash

ANDROID_SDK=$HOME/Android/sdk
ANDROID_NDK=$ANDROID_SDK/ndk/26.1.10909125
cmake -B build-android \
  -GNinja \
  -DCMAKE_TOOLCHAIN_FILE=$HOME/Qt/6.11.0/android_arm64_v8a/lib/cmake/Qt6/qt.toolchain.cmake \
  -DQT_HOST_PATH=$HOME/Qt/6.11.0/gcc_64 \
  -DANDROID_SDK_ROOT=$ANDROID_SDK \
  -DANDROID_NDK_ROOT=$ANDROID_NDK

cmake --build build-android --target apk
