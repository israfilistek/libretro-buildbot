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
  ARCH="x86_64" 
  echo Building RetroArch ...
  # build frontend
  cd /root/libretro-super
  ./retroarch-build.sh
  
  rm -rf /output/linux/${ARCH}/RetroArch/*
  mkdir -p /output/linux/${ARCH}/RetroArch/files
  cd /root/libretro-super/retroarch/
  make DESTDIR=/output/linux/${ARCH}/RetroArch/files install
  
  7za a -r /output/linux/${ARCH}/RetroArch.7z /output/linux/${ARCH}/RetroArch/files/*
}

# builds all the cores
linux_cores()
{
  ARCH="x86_64"
  echo Building cores...
  # build cores
  rm -rf /root/libretro-super/dist/unix*
  cd /root/libretro-super
  ./libretro-build.sh
  
  rm -rf /output/linux/${ARCH}/cores/
  mkdir -p /output/linux/${ARCH}/cores
  cd /root/libretro-super
  ./libretro-install.sh /output/linux/${ARCH}/cores
  
  
  7za a -r /output/linux/${ARCH}/cores.7z /output/linux/${ARCH}/cores/*
}

# builds the android frontend and cores and packages into an apk
android_all()
{
  ARCH="armeabi-v7a"
  echo Building for Android ...
  # build cores
  rm -rf /root/libretro-super/dist/android/${ARCH}/*
  cd /root/libretro-super/
  ./libretro-build-android-mk.sh
  
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
  cp -r /root/libretro-super/dist/android/${ARCH} /root/libretro-super/retroarch/android/phoenix/assets/cores
  cp -r /root/libretro-super/dist/info /root/libretro-super/retroarch/android/phoenix/assets/
  cp -r /root/libretro-super/retroarch/media/shaders /root/libretro-super/retroarch/android/phoenix/assets/shaders_glsl
  cp -r /root/libretro-super/retroarch/media/overlays /root/libretro-super/retroarch/android/phoenix/assets/
  cp -r /root/libretro-super/retroarch/media/autoconfig /root/libretro-super/retroarch/android/phoenix/assets/
  
  # clean and build
  #TODO: modify build architecture here
  NDK_TOOLCHAIN_VERSION=4.8 ant clean
  NDK_TOOLCHAIN_VERSION=4.8 ant release
  
  # sign the apk
  jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -storepass libretro -keystore /root/android-tools/my-release-key.keystore /root/libretro-super/retroarch/android/phoenix/bin/retroarch-release-unsigned.apk retroarch
  
  rm -rf /output/android/${ARCH}/*
  mkdir -p /output/android/${ARCH}/cores
  cp /root/libretro-super/retroarch/android/phoenix/assets/cores/* /output/android/${ARCH}/cores/
  7za a -r /output/android/${ARCH}/cores.7z /output/android/${ARCH}/cores/*
  
  # zipalign
  `find /root/android-tools/android-sdk-linux/ -name zipalign` -v 4 /root/libretro-super/retroarch/android/phoenix/bin/retroarch-release-unsigned.apk /output/android/${ARCH}/RetroArch.apk
}


if [ $1 ]; then
  update_code
  $1 || echo "Non-zero return from build."
fi
