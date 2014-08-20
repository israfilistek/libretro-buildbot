#!/bin/bash -e
# this script lives in each of the Docker build images and initiates and
# manages fetching new code and doing the actual compilation and moving the generated binaries to /staging

#TODO: need to loop through ARCH strings to grab all cores

# grabs the latest code for all of libretro
update_code()
{
  echo "Updating code..."
  cd /root/
  repo sync
  repo forall -c git submodule update --init
  /root/libretro-super/libretro-config.sh
}

# builds the front end for linux
linux_retroarch()
{
  ARCH="x86_64" 
  echo "Building RetroArch ..."
  # build frontend
  cd /root/libretro-super
  ./retroarch-build.sh
  
  rm -rf /staging/linux/${ARCH}/RetroArch/*
  mkdir -p /staging/linux/${ARCH}/RetroArch/files
  cd /root/libretro-super/retroarch/
  make DESTDIR=/staging/linux/${ARCH}/RetroArch/files install
  
  7za a -r /staging/linux/${ARCH}/RetroArch.7z /staging/linux/${ARCH}/RetroArch/files/*
}

# builds the windows cores
windows_cores()
{
  declare -a ARCHES=("x86_64" "x86")

  for b in "${ARCHES[@]}"
  do
    echo "Building ${b} windows cores..."
    # build cores
    rm -rf /root/libretro-super/dist/win*
    cd /root/libretro-super
    if [[ ${b} == "x86" ]]; then
      CC=i686-w64-mingw32-gcc CXX=i686-w64-mingw32-g++ platform=mingw ./libretro-build.sh
    fi
    if [[ ${b} == "x86_64" ]]; then
      CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ platform=mingw ./libretro-build.sh
    fi
  
    rm -rf /staging/windows/${b}/cores/
    mkdir -p /staging/windows/${b}/cores
    cd /root/libretro-super
    platform=mingw ./libretro-install.sh /staging/windows/${b}/cores
  
    7za a -r /staging/windows/${b}/cores.7z /staging/windows/${b}/cores/*
  done
}

# builds the linux cores
linux_cores()
{
  ARCH="x86_64"
  echo "Building linux cores..."
  # build cores
  rm -rf /root/libretro-super/dist/unix*
  cd /root/libretro-super
  ./libretro-build.sh
  
  rm -rf /staging/linux/${ARCH}/cores/
  mkdir -p /staging/linux/${ARCH}/cores
  cd /root/libretro-super
  ./libretro-install.sh /staging/linux/${ARCH}/cores
  
  7za a -r /staging/linux/${ARCH}/cores.7z /staging/linux/${ARCH}/cores/*
}

# builds the android frontend and cores and packages them into an apk
android_all()
{
  declare -a ARCHES=("x86_64" "armeabi-v7a")
  
  #convert shaders
  cd /root/libretro-super/retroarch && make -f Makefile.griffin shaders-convert-glsl
  
  for b in "${ARCHES[@]}"
  do
    echo "Building for ${b} Android ..."
    echo "export TARGET_ABIS=\"${b}\"" > /root/libretro-super/libretro-config-user.sh
    
    # build cores
    rm -rf /root/libretro-super/dist/android/${b}/*
    if [[ ${b} == "*64*" ]]; then
      export NDK_DIR=/root/android-tools/android-ndk64
    else
      export NDK_DIR=/root/android-tools/android-ndk
    fi
    export PATH=$PATH:${NDK_DIR}
    cd /root/libretro-super/ && ./libretro-build-android-mk.sh
    
    # build frontend
    android update project --target ${RA_ANDROID_API} --subprojects --path /root/libretro-super/retroarch/android/phoenix
    
    # setup paths
    rm -rf /root/libretro-super/retroarch/android/phoenix/assets
    mkdir -p /root/libretro-super/retroarch/android/phoenix/assets/autoconfig
    
    # copy cores and other assets
    cp -r /root/libretro-super/dist/android/${b} /root/libretro-super/retroarch/android/phoenix/assets/cores
    cp -r /root/libretro-super/dist/info /root/libretro-super/retroarch/android/phoenix/assets/
    cp -r /root/libretro-super/retroarch/media/shaders_glsl /root/libretro-super/retroarch/android/phoenix/assets/
    cp -r /root/libretro-super/retroarch/media/overlays /root/libretro-super/retroarch/android/phoenix/assets/
    cp -r /root/libretro-super/retroarch/media/autoconfig/android/* /root/libretro-super/retroarch/android/phoenix/assets/autoconfig/
      
    # clean before building
    cd /root/libretro-super/retroarch/android/phoenix && ant clean -Dndk.dir=${NDK_DIR}
    
    KEYSTORE=/root/android-tools/my-release-key.keystore
    if [ $KEYSTORE_PASSWORD ]; then #release build case
      echo "Release build using KEYSTORE_PASSWORD and KEYSTORE_URL environment variables."
      
      # release build
      cd /root/libretro-super/retroarch/android/phoenix && ant release -Dndk.dir=${NDK_DIR}
      
      #download the keystore
      curl ${KEYSTORE_URL} > ${KEYSTORE}
      
      # sign the apk
      jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -storepass ${KEYSTORE_PASSWORD} -keystore ${KEYSTORE} /root/libretro-super/retroarch/android/phoenix/bin/retroarch-release-unsigned.apk retroarch
      
      # delete the keystore
      rm ${KEYSTORE}
      
      # zipalign
      `find /root/android-tools/android-sdk-linux/ -name zipalign` -v 4 /root/libretro-super/retroarch/android/phoenix/bin/retroarch-release-unsigned.apk /root/libretro-super/retroarch/android/phoenix/bin/RetroArch.apk
    else #debug(nighlty) build case
      # KEYSTORE_PASSWORD=libretro
      
      # this hacks a new "debug" version of RetroArch that can be installed alongside the play store version for testing
      sed -i 's/com\.retroarch/com\.retroarchdebug/g' `grep -lr 'com\.retroarch' /root/libretro-super/retroarch/android/phoenix`
      sed -i 's/com_retroarch/com_retroarchdebug/g' `grep -lr 'com_retroarch' /root/libretro-super/retroarch/android/phoenix`
      mv /root/libretro-super/retroarch/android/phoenix/src/com/retroarch /root/libretro-super/retroarch/android/phoenix/src/com/retroarchdebug || true
      mv /root/libretro-super/retroarch/android/phoenix/jni/native/com_retroarch_browser_NativeInterface.h /root/libretro-super/retroarch/android/phoenix/jni/native/com_retroarchdebug_browser_NativeInterface.h  || true
      sed -i 's,<string name="app_name">[^<]*</string>,<string name="app_name">RetroArch Dev</string>,g' /root/libretro-super/retroarch/android/phoenix/res/values/strings.xml
      sed -i "s/android:versionCode=\"[0-9]*\"/android:versionCode=\"`date -u +%s`\"/g" /root/libretro-super/retroarch/android/phoenix/AndroidManifest.xml
      
      # build debug apk
      cd /root/libretro-super/retroarch/android/phoenix && ant debug -Dndk.dir=${NDK_DIR}
      mv /root/libretro-super/retroarch/android/phoenix/bin/retroarch-debug.apk /root/libretro-super/retroarch/android/phoenix/bin/RetroArch.apk
    fi
    
    rm -rf /staging/android/${b}/*
    mkdir -p /staging/android/${b}/cores
    
    # copy the binaries to staging
    cp /root/libretro-super/retroarch/android/phoenix/assets/cores/* /staging/android/${b}/cores/
    7za a -r /staging/android/${b}/cores.7z /root/libretro-super/dist/android/${b}/*
    cp /root/libretro-super/retroarch/android/phoenix/bin/RetroArch.apk /staging/android/${b}/RetroArch.apk
    
  done
  
  # let's not leave the debug mess in libretro-super/retroarch/android 
  cd /root/libretro-super/retroarch/android && rm -rf phoenix
  cd /root/libretro-super/retroarch/android && git stash
}


if [ $1 ]; then
  update_code
  $1 || echo "Non-zero return from build."
fi
