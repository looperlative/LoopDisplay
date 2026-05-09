# Building LoopDisplay for Android

This document covers the complete process for building LoopDisplay as an Android APK on a Linux host.

## Prerequisites

The following are already in place on this machine:

| Requirement | Status | Location |
|---|---|---|
| Qt 6.11.0 (Android ARM64) | Installed | `~/Qt/6.11.0/android_arm64_v8a` |
| Qt 6.11.0 (Linux host tools) | Installed | `~/Qt/6.11.0/gcc_64` |
| CMake | Installed | `~/Qt/Tools/CMake` |
| Ninja | Installed | `~/Qt/Tools/Ninja` |
| Java 21 (OpenJDK) | Installed | `/usr/bin/java` |
| Android SDK & NDK | **Must install** | `~/Android/sdk` |

---

## Step 1 — Install the Android SDK

Qt Creator's bundled `sdk_definitions.json` provides the canonical download URL for the command-line tools.

### 1a. Download and extract Android Command Line Tools

```bash
mkdir -p ~/Android/sdk/cmdline-tools
cd ~/Android/sdk/cmdline-tools

wget "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
     -O commandlinetools.zip

# Verify integrity (optional but recommended)
echo "2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258  commandlinetools.zip" | sha256sum -c

# sdkmanager requires the tools to be at cmdline-tools/latest/
unzip -q commandlinetools.zip
mv cmdline-tools latest
rm commandlinetools.zip
```

After extraction the layout must be:
```
~/Android/sdk/
  cmdline-tools/
    latest/
      bin/
        sdkmanager
        avdmanager
      ...
```

### 1b. Set environment variables

Add these to your `~/.bashrc` or `~/.profile` (and source the file, or open a new terminal):

```bash
export ANDROID_SDK_ROOT=$HOME/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
```

### 1c. Accept licenses (interactive — must be run manually)

This step requires keyboard input to accept each license. Run it yourself:

```bash
sdkmanager --licenses
```

Press `y` followed by Enter for each prompt. There are typically 5–7 licenses to accept.

### 1d. Install SDK components

```bash
sdkmanager "platform-tools" \
           "build-tools;36.0.0" \
           "platforms;android-36" \
           "ndk;26.1.10909125"
```

This installs:
- `platform-tools` — `adb`, `fastboot`
- `build-tools;36.0.0` — `aapt2`, `d8`, `zipalign`. Qt 6.11 uses AGP 9.0 which enforces build tools ≥ 36.
- `platforms;android-36` — Android 16 SDK (API 36). AGP 9.0 + `androidx.core:core:1.17.0` require `compileSdk ≥ 36`.
- `ndk;26.1.10909125` — NDK r26b, the version recommended for Qt 6.7+

After installation the NDK will be at:
```
~/Android/sdk/ndk/26.1.10909125/
```

---

## Step 2 — Build the APK

From the project root (`~/Sources/LoopDisplay`):

```bash
./build-android.sh
```

What the script does:

```bash
ANDROID_SDK=$HOME/Android/sdk
ANDROID_NDK=$ANDROID_SDK/ndk/26.1.10909125

cmake -B build-android \
  -GNinja \
  -DCMAKE_TOOLCHAIN_FILE=$HOME/Qt/6.11.0/android_arm64_v8a/lib/cmake/Qt6/qt.toolchain.cmake \
  -DQT_HOST_PATH=$HOME/Qt/6.11.0/gcc_64 \
  -DANDROID_SDK_ROOT=$ANDROID_SDK \
  -DANDROID_NDK_ROOT=$ANDROID_NDK

cmake --build build-android --target apk
```

Key parameters:

| Parameter | Purpose |
|---|---|
| `CMAKE_TOOLCHAIN_FILE` | Qt's Android toolchain (wraps NDK toolchain, sets ABI to arm64-v8a) |
| `QT_HOST_PATH` | Linux host tools (`moc`, `rcc`, `qmlcachegen`) used during cross-compilation |
| `ANDROID_SDK_ROOT` | Android SDK for Gradle and build tools |
| `ANDROID_NDK_ROOT` | NDK for the C++ cross-compiler |

### Output APK location

```
build-android/android-build/build/outputs/apk/debug/android-build-debug.apk
```

---

## Step 3 — Deploy to a Device

### Enable USB debugging on the Android device

1. Settings → About phone → tap **Build number** 7 times to unlock Developer Options
2. Settings → Developer options → enable **USB debugging**
3. Connect the device via USB and accept the authorization prompt on the phone

### Install the APK

```bash
# Verify the device is detected
adb devices

# Install
adb install build-android/android-build/build/outputs/apk/debug/android-build-debug.apk
```

### View log output (optional)

```bash
adb logcat -s Qt
```

---

## Android Manifest

The custom manifest at `android/AndroidManifest.xml` declares three permissions required for LP1 communication:

| Permission | Reason |
|---|---|
| `INTERNET` | UDP socket for status polling |
| `ACCESS_NETWORK_STATE` | Check network availability |
| `CHANGE_WIFI_MULTICAST_STATE` | UDP broadcast for device discovery |

Qt's build system merges this manifest with its own auto-generated one (Qt activity declaration, etc.).

---

## CMake Changes

`src/CMakeLists.txt` was extended with an Android block:

```cmake
if(ANDROID)
  set_target_properties(LoopDisplay PROPERTIES
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android"
    QT_ANDROID_TARGET_SDK_VERSION 36
  )
endif()
```

`QT_ANDROID_PACKAGE_SOURCE_DIR` tells Qt CMake to overlay the `android/` directory on top of the auto-generated package source. Files present there (like `AndroidManifest.xml`) override the auto-generated versions.

---

## Building for Other ABIs

Qt 6.11.0 ships with libraries for four Android architectures. To build for a different one, change the `CMAKE_TOOLCHAIN_FILE` and output directory in `build-android.sh`:

| ABI | Qt directory | Device type |
|---|---|---|
| `arm64-v8a` (default) | `android_arm64_v8a` | Modern 64-bit phones (2015+) |
| `armeabi-v7a` | `android_armv7` | Older 32-bit ARM devices |
| `x86_64` | `android_x86_64` | Android emulator (64-bit) |
| `x86` | `android_x86` | Android emulator (32-bit) |

Example for ARMv7:

```bash
cmake -B build-android-armv7 \
  -GNinja \
  -DCMAKE_TOOLCHAIN_FILE=$HOME/Qt/6.11.0/android_armv7/lib/cmake/Qt6/qt.toolchain.cmake \
  -DQT_HOST_PATH=$HOME/Qt/6.11.0/gcc_64 \
  -DANDROID_SDK_ROOT=$HOME/Android/sdk \
  -DANDROID_NDK_ROOT=$HOME/Android/sdk/ndk/26.1.10909125

cmake --build build-android-armv7 --target apk
```

---

## Troubleshooting

### `sdkmanager: command not found`

The `cmdline-tools/latest/bin` directory is not on your `PATH`. Make sure you have sourced your shell config after setting `PATH` in Step 1b.

### `CMake Error: Qt requires a host build`

`QT_HOST_PATH` was not set or points to the wrong directory. It must point to the **Linux** Qt installation (`gcc_64`), not the Android one.

### `Gradle build failed: SDK location not found`

`ANDROID_SDK_ROOT` is not set or the SDK was not installed correctly. Verify:
```bash
ls ~/Android/sdk/platform-tools/adb
ls ~/Android/sdk/build-tools/36.0.0/
ls ~/Android/sdk/ndk/26.1.10909125/
```

### App launches but cannot find LP1 device

- Ensure the Android device is on the same WiFi network as the LP1.
- Some Android versions require the user to explicitly grant `CHANGE_WIFI_MULTICAST_STATE` at runtime through system settings.
- Check `adb logcat -s Qt` for UDP errors.

### Signing for release distribution

The APK produced by `build-android.sh` is a debug-signed APK suitable for direct `adb install`. For Google Play distribution a release keystore is required. See Qt's [Android deployment documentation](https://doc.qt.io/qt-6/android-deploy-qt-tool.html) for signing configuration.
