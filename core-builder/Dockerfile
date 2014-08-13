#this is the Arch Linux base
FROM base/devel:latest
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment, grab the source code
RUN pacman -Suy --noconfirm
RUN git config --global user.email "buildbot@libretro.com"
RUN git config --global user.name "Build Bot"

# setup repo
RUN pacman -Suy --noconfirm python2
ADD https://storage.googleapis.com/git-repo-downloads/repo /bin/repo
RUN sed -i 's/python/python2/g' /bin/repo
RUN chmod a+x /bin/repo

# get the source code
WORKDIR /root/
RUN repo init -u https://github.com/libretro/libretro-manifest.git
RUN repo sync
RUN repo forall -c git submodule update --init

#setup ccache
RUN pacman -Suy --noconfirm ccache
RUN mkdir /ccache
ENV CCACHE_DIR /ccache
ENV PATH /usr/lib/ccache/bin:$PATH
RUN ccache -M 6

# our one open-gl dependancy
RUN pacman -Suy --noconfirm mesa-libgl

# build the cores now to populate ccache
WORKDIR /root/libretro-super/
RUN ./libretro-build.sh

# Android setup section
RUN pacman -Suy --noconfirm apache-ant
RUN mkdir /root/android-tools

# Android SDK
ADD https://dl.google.com/android/android-sdk_r23.0.2-linux.tgz /root/android-tools/android-sdk.tgz
RUN tar -xvf /root/android-tools/android-sdk.tgz -C /root/android-tools/
RUN rm -rf /root/android-tools/android-sdk.tgz
ENV PATH $PATH:/root/android-tools/android-sdk-linux/tools

# Android NDK
ADD https://dl.google.com/android/ndk/android-ndk32-r10-linux-x86_64.tar.bz2 /root/android-tools/android-ndk.tar.bz2
RUN tar -xvf /root/android-tools/android-ndk.tar.bz2 -C /root/android-tools/
RUN rm -rf /root/android-tools/android-ndk.tar.bz2
RUN mv /root/android-tools/android-ndk-* /root/android-tools/android-ndk
ENV PATH $PATH:/root/android-tools/android-ndk

# for optional signing of release  apk
RUN keytool -genkey -keystore /root/android-tools/my-release-key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000 -storepass libretro -keypass libretro -dname "cn=localhost, ou=IT, o=libretro, c=US"

# TODO: enable ccache for android core builds

# build android cores to populate ccache
RUN NDK_TOOLCHAIN_VERSION=4.8 ./libretro-build-android-mk.sh

# update/install android sdk components
RUN pacman -Suy --noconfirm expect
ADD https://raw.githubusercontent.com/l3iggs/libretro-buildbot/master/core-builder/android-sdk-installer.py /root/android-tools/android-sdk-installer.py
RUN python2 /root/android-tools/android-sdk-installer.py

# win x86_64 setup section
#RUN pacman -Suy --noconfirm mingw-w64-toolchain zip unzip wget

# for working in the image
RUN pacman -Suy --noconfirm vim

# for packaging outputs
RUN pacman -Suy --noconfirm p7zip

WORKDIR /root/

#add the build script
ADD https://raw.githubusercontent.com/l3iggs/libretro-buildbot/master/core-builder/lr-build.sh /bin/lr-build
RUN chmod a+x /bin/lr-build

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
CMD lr-build
