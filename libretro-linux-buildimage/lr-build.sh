#!/bin/bash

updateCode()
{
  echo Updating code...
  repo sync
  repo forall -c git submodule update --init
}

linux_x86_64()
{
  echo Building for Linux x86_64...
  rm -rf /output/linux/x86_64/
  mkdir -p /output/linux/x86_64/cores
  mkdir -p /nightly/linux/x86_64
  cd libretro-super
  ./retroarch-build.sh
  ./libretro-build.sh
  ./libretro-install.sh /output/linux/x86_64/cores
  cd retroarch/
  make DESTDIR=/output/linux/x86_64 install
  7za a -r /nightly/linux/x86_64/$(date +"%Y-%m-%d_%T")_retroarch-linux_x86_64.7z /output/linux/x86_64/*
}

android_armeabi-v7a()
{
  echo Building for Android armeabi-v7a...
  mkdir -p /nightly/android/armeabi-v7a
  rm -rf /output/android/armeabi-v7a/
  rm -rf /root/libretro-super/retroarch/android/phoenix/assets
  mkdir -p /output/android/assets/armeabi-v7a/assets/cores
  mkdir -p /output/android/assets/armeabi-v7a/assets/overlays
  
  #build the cores
  cd libretrosuper
  #TODO: ./libretro-build-android-mk.sh #it would be nice to run this through ccache too if possible
  
  #build retroarch
  cd retroarch/android/phoenix
  mkdir -p assets/cores
  mkdir assets/overlays
  echo TODO
  #cp /root/libretro-super/dist/android/armeabi-v7a/* asets/cores
  cp /root/libretro-super/dist/info/* asets/cores
  cp /root/libretro-super/libretro-overlays/* asets/overlays
  #ant clean
  #ant release
  #TODO: sign the apk here
  
  #cp bin/release.apk /nightly/android/armeabi-v7a/$(date +"%Y-%m-%d_%T")_android-armeabi-v7a.apk
}


if [ $1 ]; then
  updateCode
  $1
else
  updateCode
  linux_x86_64
  android_armeabi-v7a
fi
