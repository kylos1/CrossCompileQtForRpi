#!/bin/bash

# Script to sync Raspberry Pi system Qt6 binaries

# Automatically detect current user
USER_HOME="/home/$USER"

# Go to qt6 directory
cd "$USER_HOME/qt6" || exit 1

rm -rf pi-build
mkdir pi-build && cd pi-build || exit 1

# Cmake command to configure using raspberrypi sysroot
cd pi-build
cmake ../src/qtbase-everywhere-src-6.5.1/ -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DINPUT_opengl=es2 \
  -DQT_BUILD_EXAMPLES=OFF \
  -DQT_BUILD_TESTS=OFF \
  -DQT_HOST_PATH=$HOME/qt6/host \
  -DCMAKE_STAGING_PREFIX=$HOME/qt6/pi \
  -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
  -DCMAKE_TOOLCHAIN_FILE=$HOME/qt6/toolchain.cmake \
  -DQT_QMAKE_TARGET_MKSPEC=devices/linux-rasp-pi4-aarch64 \
  -DQT_FEATURE_xcb=ON \
  -DFEATURE_xcb_xlib=ON \
  -DQT_FEATURE_xlib=ON

if cmake --build . --parallel 8 && cmake --install .; then
    echo "Build successful. Sending binaries to raspberrypi..."
    rsync -avz --delete --rsync-path="sudo rsync" $HOME/qt6/pi/ pi@raspberrypi.local:/usr/local/qt6
else
    echo "Build failed. Not syncing binaries."
    exit 1
fi
