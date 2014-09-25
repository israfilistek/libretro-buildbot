#this prepares the android build environment
FROM libretro/arch-base:latest
MAINTAINER l3iggs <l3iggs@live.com>

# Android setup section
RUN pacman -Suy --noconfirm apache-ant python3 nvidia-cg-toolkit
RUN mkdir /root/android-tools

# Android SDK
ADD https://dl.google.com/android/android-sdk_r23.0.2-linux.tgz /root/android-tools/android-sdk.tgz
RUN tar -xvf /root/android-tools/android-sdk.tgz -C /root/android-tools/
RUN rm -rf /root/android-tools/android-sdk.tgz
ENV PATH $PATH:/root/android-tools/android-sdk-linux/tools
ENV ANDROID_HOME /root/android-tools/android-sdk-linux
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/build-android/debug.keystore /.android/debug.keystore
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/build-android/debug.keystore /root/.android/debug.keystore

#need to be able to run 32bit programs for some SDK pieces
RUN echo "[multilib]" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
RUN pacman -Suy --noconfirm lib32-glibc lib32-zlib lib32-ncurses lib32-gcc-libs

# Android NDK r10b for 32 bit targets
ADD https://dl.google.com/android/ndk/android-ndk32-r10b-linux-x86_64.tar.bz2 /root/android-tools/android-ndk.tar.bz2
RUN tar -xvf /root/android-tools/android-ndk.tar.bz2 -C /root/android-tools/
RUN rm -rf /root/android-tools/android-ndk.tar.bz2
RUN mv /root/android-tools/android-ndk-* /root/android-tools/android-ndk
#ENV PATH $PATH:/root/android-tools/android-ndk
#ENV ndk.dir /root/android-tools/android-ndk
#ENV NDK_TOOLCHAIN_VERSION 4.8

# Android NDK r10b for 64 bit targets
ADD https://dl.google.com/android/ndk/android-ndk64-r10b-linux-x86_64.tar.bz2 /root/android-tools/android-ndk64.tar.bz2
RUN tar -xvf /root/android-tools/android-ndk64.tar.bz2 -C /root/android-tools/
RUN rm -rf /root/android-tools/android-ndk64.tar.bz2
RUN mv /root/android-tools/android-ndk-* /root/android-tools/android-ndk64
#ENV PATH $PATH:/root/android-tools/android-ndk
#ENV ndk.dir /root/android-tools/android-ndk
#ENV NDK_TOOLCHAIN_VERSION 4.8

# standalone NDK32 (platform 9 too low?)
RUN mkdir /root/android-tools/ndk-toolchain
RUN /root/android-tools/android-ndk/build/tools/make-standalone-toolchain.sh --platform=android-9 --toolchain=arm-linux-androideabi-4.8 --install-dir=/root/android-tools/ndk-toolchain
# --toolchain here should be one of: arm-linux-androideabi-4.6 arm-linux-androideabi-4.8 arm-linux-androideabi-clang3.3 arm-linux-androideabi-clang3.4 llvm-3.3 llvm-3.4 mipsel-linux-android-4.6 mipsel-linux-android-4.8 mipsel-linux-android-clang3.3 mipsel-linux-android-clang3.4 renderscript x86-4.6 x86-4.8 x86-clang3.3 x86-clang3.4

# standalone NDK64
RUN mkdir /root/android-tools/ndk-toolchain64
RUN /root/android-tools/android-ndk64/build/tools/make-standalone-toolchain.sh --platform=android-L --toolchain=x86_64-4.9  --install-dir=/root/android-tools/ndk-toolchain64
# --toolchain here should be one of: aarch64-linux-android-4.9 aarch64-linux-android-clang3.4 arm-linux-androideabi-4.9 llvm-3.4 mips64el-linux-android-4.9 mips64el-linux-android-clang3.4 mipsel-linux-android-4.9 x86-4.9 x86_64-4.9 x86_64-clang3.4

# for optional signing of release  apk
# RUN keytool -genkey -v -keystore /root/android-tools/my-release-key.keystore -alias retroarch -keyalg RSA -keysize 2048 -validity 10000 -storepass libretro -keypass libretro -dname "cn=localhost, ou=IT, o=libretro, c=US"

# update/install android sdk components
RUN pacman -Suy --noconfirm expect
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/build-android/android-sdk-installer.py /root/android-tools/android-sdk-installer.py
RUN python2 /root/android-tools/android-sdk-installer.py

# for working in the image
RUN pacman -Suy --noconfirm vim

# for packaging outputs
RUN pacman -Suy --noconfirm p7zip zip

# enable ccache for NDK builds
ENV NDK_CCACHE ccache

# setup repo for this project
RUN cd /root/ && repo init -u https://github.com/libretro/libretro-manifest.git

# add the bootstrap script
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/master/bootstrap.sh /bin/bootstrap.sh
RUN chmod a+x /bin/bootstrap.sh

# build once now to populate ccache
RUN bootstrap.sh android

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
ENTRYPOINT bootstrap.sh android
