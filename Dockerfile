#this prepares the android build environment
FROM libretro/arch-base:latest
MAINTAINER l3iggs <l3iggs@live.com>

# Android setup section
RUN pacman -Suy --noconfirm apache-ant
RUN mkdir /root/android-tools

# Android SDK
ADD https://dl.google.com/android/android-sdk_r23.0.2-linux.tgz /root/android-tools/android-sdk.tgz
RUN tar -xvf /root/android-tools/android-sdk.tgz -C /root/android-tools/
RUN rm -rf /root/android-tools/android-sdk.tgz
ENV PATH $PATH:/root/android-tools/android-sdk-linux/tools
ENV ANDROID_HOME /root/android-tools/android-sdk-linux
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/android-setup/debug.keystore /.android/debug.keystore
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/android-setup/debug.keystore /root/.android/debug.keystore

#need to be able to run 32bit programs for some SDK pieces
RUN echo "[multilib]" >> /etc/pacman.conf 
RUN echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf 
RUN pacman -Suy --noconfirm lib32-glibc lib32-zlib lib32-ncurses lib32-gcc-libs

# Android NDK for 32 bit targets
ADD https://dl.google.com/android/ndk/android-ndk32-r10-linux-x86_64.tar.bz2 /root/android-tools/android-ndk.tar.bz2
RUN tar -xvf /root/android-tools/android-ndk.tar.bz2 -C /root/android-tools/
RUN rm -rf /root/android-tools/android-ndk.tar.bz2
RUN mv /root/android-tools/android-ndk-* /root/android-tools/android-ndk
#ENV PATH $PATH:/root/android-tools/android-ndk
#ENV ndk.dir /root/android-tools/android-ndk
#ENV NDK_TOOLCHAIN_VERSION 4.8

# Android NDK for 64 bit targets
ADD https://dl.google.com/android/ndk/android-ndk64-r10-linux-x86_64.tar.bz2 /root/android-tools/android-ndk64.tar.bz2
RUN tar -xvf /root/android-tools/android-ndk64.tar.bz2 -C /root/android-tools/
RUN rm -rf /root/android-tools/android-ndk64.tar.bz2
RUN mv /root/android-tools/android-ndk-* /root/android-tools/android-ndk64
#ENV PATH $PATH:/root/android-tools/android-ndk
#ENV ndk.dir /root/android-tools/android-ndk
#ENV NDK_TOOLCHAIN_VERSION 4.8

# standalone NDK32 (platform 9 too low?)
RUN mkdir /root/android-tools/ndk-toolchain
RUN /root/android-tools/android-ndk/build/tools/make-standalone-toolchain.sh --platform=android-9 --install-dir=/root/android-tools/ndk-toolchain

# standalone NDK64 (android-L is the loest available at the moment)
RUN mkdir /root/android-tools/ndk-toolchain64
RUN /root/android-tools/android-ndk64/build/tools/make-standalone-toolchain.sh --platform=android-L --install-dir=/root/android-tools/ndk-toolchain64

# for optional signing of release  apk
# RUN keytool -genkey -v -keystore /root/android-tools/my-release-key.keystore -alias retroarch -keyalg RSA -keysize 2048 -validity 10000 -storepass libretro -keypass libretro -dname "cn=localhost, ou=IT, o=libretro, c=US"

# update/install android sdk components
RUN pacman -Suy --noconfirm expect
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/android-setup/android-sdk-installer.py /root/android-tools/android-sdk-installer.py
RUN python2 /root/android-tools/android-sdk-installer.py

# for working in the image
RUN pacman -Suy --noconfirm vim

# for packaging outputs
RUN pacman -Suy --noconfirm p7zip

# enable ccache for NDK builds
ENV NDK_CCACHE ccache
