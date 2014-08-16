#!/bin/bash

# grabs the latest code for all of libretro
update_code()
{
  echo Updating code...
  cd /root/
  repo sync
  repo forall -c git submodule update --init
}

# builds the front end
linux_retroarch()
{
  rm -rf /output/linux/
  mkdir -p /output/linux/
  mkdir -p /nightly/linux/
  
  
  # build frontend
  cd /root/libretro-super
  ./retroarch-build.sh
  cd /root/libretro-super/retroarch/
  make DESTDIR=/output/linux/ install
  7za a -r /nightly/linux/$(date +"%Y-%m-%d_%T")_retroarch-linux.7z /output/linux/*
}

# builds all the cores
linux_cores()
{
  echo Building cores ...
  rm -rf /output/linux/
  rm -rf /root/libretro-super/dist/unix*
  mkdir -p /output/linux/cores
  mkdir -p /nightly/linux/
  
  # build cores
  cd /root/libretro-super
  ./libretro-build.sh
  ./libretro-install.sh /output/linux/cores
  
  7za a -r /nightly/linux/$(date +"%Y-%m-%d_%T")_libretro-cores-linux.7z /output/linux/*
}

# builds the android frontend and cores and packages into an apk
android_all()
{
  echo Building for Android ...
  rm -rf /output/android/
  rm -rf /root/libretro-super/dist/android*
  mkdir -p /output/android/cores 
  mkdir -p /nightly/android

  # build cores
  cd /root/libretro-super/
  ./libretro-build-android-mk.sh
  
  # build frontend
  cd /root/libretro-super/retroarch/android/phoenix
  android update project --path .
  echo "ndk.dir=/root/android-tools/android-ndk" >> local.properties
  android update project --path libs/googleplay/
  android update project --path libs/appcompat/
  
  # setup paths
  rm -rf assets
  mkdir -p assets/cores
  mkdir assets/overlays
  
  # copy cores and other assets
  #TODO: refactor for any target
  cp /root/libretro-super/dist/android/armeabi-v7a/* assets/cores/	
  cp -r /root/libretro-super/dist/info/ assets/
  cp -r /root/libretro-super/libretro-overlays/* assets/overlays/
  
  # clean and build
  NDK_TOOLCHAIN_VERSION=4.8 ant clean
  NDK_TOOLCHAIN_VERSION=4.8 ant release
  
  # sign the apk
  jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -storepass libretro -keystore /root/android-tools/my-release-key.keystore /root/libretro-super/retroarch/android/phoenix/bin/retroarch-release-unsigned.apk retroarch
  
  # zipalign
  `find /root/android-tools/android-sdk-linux/ -name zipalign` -v 4 /root/libretro-super/retroarch/android/phoenix/bin/retroarch-release-unsigned.apk /nightly/android/$(date +"%Y-%m-%d_%T")_android.apk
}


if [ $1 ]; then
  update_code
  $1
fi
