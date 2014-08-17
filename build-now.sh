#!/bin/bash -e

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
  echo Building RetroArch ...
  # build frontend
  cd /root/libretro-super
  ./retroarch-build.sh
  
  rm -rf /output/linux/RetroArch/*
  mkdir -p /output/linux/RetroArch/files
  cd /root/libretro-super/retroarch/
  make DESTDIR=/output/linux/RetroArch/files install
  
  7za a -r /output/linux/RetroArch.7z /output/linux/RetroArch/files/*
}

# builds all the cores
linux_cores()
{
  echo Building cores...
  # build cores
  rm -rf /root/libretro-super/dist/unix*
  cd /root/libretro-super
  ./libretro-build.sh
  
  rm -rf /output/linux/cores/*
  mkdir -p /output/linux/cores/files
  cd /root/libretro-super
  ./libretro-install.sh /output/linux/cores/files
  
  
  7za a -r /output/linux/cores.7z /output/linux/cores/files/*
}

# builds the android frontend and cores and packages into an apk
android_all()
{
  echo Building for Android ...
  # build cores
  rm -rf /root/libretro-super/dist/android*
  cd /root/libretro-super/
  ./libretro-build-android-mk.sh
  
  mkdir -p /nightly/android
  
  # build frontend
  cd /root/libretro-super/retroarch/android/phoenix
  android update project --path .
  echo "ndk.dir=/root/android-tools/android-ndk" >> local.properties
  android update project --path libs/googleplay/
  android update project --path libs/appcompat/
  
  # setup paths
  rm -rf /root/libretro-super/retroarch/android/phoenix/assets
  mkdir -p /root/libretro-super/retroarch/android/phoenix/assets/
  
  # copy cores and other assets
  #TODO: refactor for any target
  cp -r /root/libretro-super/dist/android/armeabi-v7a /root/libretro-super/retroarch/android/phoenix/assets/cores
  cp -r /root/libretro-super/dist/info /root/libretro-super/retroarch/android/phoenix/assets/
  cp -r /root/libretro-super/retroarch/media/shaders /root/libretro-super/retroarch/android/phoenix/assets/shaders_glsl
  cp -r /root/libretro-super/retroarch/media/overlays /root/libretro-super/retroarch/android/phoenix/assets/
  cp -r /root/libretro-super/retroarch/media/autoconfig /root/libretro-super/retroarch/android/phoenix/assets/
  
  # clean and build
  NDK_TOOLCHAIN_VERSION=4.8 ant clean
  NDK_TOOLCHAIN_VERSION=4.8 ant release
  
  # sign the apk
  jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -storepass libretro -keystore /root/android-tools/my-release-key.keystore /root/libretro-super/retroarch/android/phoenix/bin/retroarch-release-unsigned.apk retroarch
  
  rm -rf /output/android/*
  mkdir -p /output/android/cores
  cp /root/libretro-super/retroarch/android/phoenix/assets/cores/* /output/android/cores/
  7za a -r /output/android/cores.7z /output/android/cores/*
  
  # zipalign
  `find /root/android-tools/android-sdk-linux/ -name zipalign` -v 4 /root/libretro-super/retroarch/android/phoenix/bin/retroarch-release-unsigned.apk /output/android/RetroArch.apk
}


if [ $1 ]; then
  update_code
  $1
fi
