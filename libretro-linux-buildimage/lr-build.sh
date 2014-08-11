#!/bin/bash

linux_x86_64()
{
  echo Building for Linux...
  mkdir -p /output/linux/x86_64/cores
  mkdir -p /nightly/linux/x86_64
  repo sync
  repo forall -c git submodule update --init
  cd libretro-super
  ./retroarch-build.sh
  ./libretro-build.sh
  ./libretro-install.sh /output/linux/x86_64/cores
  cd retroarch/
  make DESTDIR=/output/linux/x86_64 install
  7za a -r /nightly/linux/x86_64/$(date +"%Y-%m-%d_%T")_retroarch-linux_x86_64.7z /output/linux/x86_64/*
}


android()
{
  echo Building for Android...
  echo TODO
}


if [ $1 ]; then
   $1
else
  linux_x86_64
  android
fi
