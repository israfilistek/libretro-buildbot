#!/bin/bash

updateCode()
{
  echo Updating code...
  repo sync
  repo forall -c git submodule update --init
}

linux_x86_64()
{
  echo Building cores for Linux x86_64...
  rm -rf /output/linux/x86_64/
  rm -rf /root/libretro-super/dist/unix*
  mkdir -p /output/linux/x86_64/cores
  mkdir -p /nightly/linux/x86_64
  cd libretro-super
  ./retroarch-build.sh
  #./libretro-build.sh
  ./libretro-install.sh /output/linux/x86_64/cores
  #cd retroarch/
  #make DESTDIR=/output/linux/x86_64 install
  7za a -r /nightly/linux/x86_64/$(date +"%Y-%m-%d_%T")_retroarch-linux_x86_64.7z /output/linux/x86_64/*
}

android_armeabi-v7a()
{
  echo Building for Android armeabi-v7a...
  rm -rf /output/android/armeabi-v7a/
  rm -rf /root/libretro-super/dist/android
  mkdir -p /output/android/armeabi-v7a/cores 
  mkdir -p /nightly/android/armeabi-v7a

  # build cores
  cd /root/libretro-super/
  NOCLEAN=1 ./libretro-build-android-mk.sh #TODO: remove NOCLEAN when ccache is working for android builds
  
  # build android frontend
  ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter android-17
  ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter platform-tools
  ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter addon-google_apis-google-17
  cd /root/libretro-super/retroarch/android/phoenix
  android update project --path .
  echo "ndk.dir=/root/android-tools/android-ndk" >> local.properties
  android update project --path libs/googleplay/
  android update project --path libs/appcompat/
  
  rm -rf assets
  mkdir -p assets/cores
  mkdir assets/overlays
  #TODO: refactor for any target
  cp /root/libretro-super/dist/android/armeabi-v7a/* assets/cores/	
  cp -r /root/libretro-super/dist/info/ assets/
  cp -r /root/libretro-super/libretro-overlays/* assets/overlays/
  ant clean
  ant debug #TODO, make release and sign
  cp bin/retroarch-debug.apk /nightly/android/armeabi-v7a/$(date +"%Y-%m-%d_%T")_android-armeabi-v7a.apk
}


if [ $1 ]; then
  updateCode
  $1
else
  updateCode
  linux_x86_64
  android_armeabi-v7a
fi
