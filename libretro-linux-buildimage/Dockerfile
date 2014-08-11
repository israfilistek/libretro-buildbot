#this is the Arch Linux base
FROM base/devel:latest
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment, grab the source code
RUN pacman -Suy --noconfirm p7zip vim python2 ccache expect
RUN mkdir /ccache
ENV CCACHE_DIR /ccache
ENV PATH /usr/lib/ccache/bin:$PATH
RUN ccache -M 6
RUN git config --global user.email "buildbot@libretro.com"
RUN git config --global user.name "Build Bot"
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo
RUN sed -i 's/python/python2/g' /bin/repo
RUN chmod a+x /bin/repo
WORKDIR /root/
RUN repo init -u https://github.com/libretro/libretro-manifest.git
RUN repo sync
RUN repo forall -c git submodule update --init

# linux x86_64 setup section
# build the cores now to populate ccache
WORKDIR /root/libretro-super/
RUN ./libretro-build.sh

#for ffmpeg static
#RUN pacman -Suy --noconfirm cmake mercurial
RUN git clone https://github.com/stvs/ffmpeg-static.git
WORKDIR /root/ffmpeg-static
RUN ./build.sh
#TODO: point ra's makefile at these .a files

#for retroarch
#ffmpeg python glu
RUN pacman -Suy --noconfirm nvidia-cg-toolkit mesa-libgl sdl libxkbcommon libxinerama libxv clang

# build retroarch now to populate ccache
WORKDIR /root/libretro-super/
RUN ./retroarch-build.sh

# win x86_64 setup section
RUN pacman -Suy --noconfirm mingw-w64-toolchain zip unzip wget

# Android setup section
ENV SDK_URL https://dl.google.com/android/android-sdk_r23.0.2-linux.tgz
ENV NDK_URL https://dl.google.com/android/ndk/android-ndk32-r10-linux-x86_64.tar.bz2
RUN pacman -Suy --noconfirm apache-ant
RUN mkdir /root/android-tools
WORKDIR /root/android-tools/
RUN keytool -genkey -keystore /root/android-tools/my-release-key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000 -storepass libretro -keypass libretro -dname "cn=localhost, ou=IT, o=libretro, c=US"

RUN curl ${SDK_URL} > /root/android-tools/android-sdk.tgz
RUN tar -xf android-sdk.tgz
RUN rm android-sdk.tgz
ENV PATH $PATH:/root/android-tools/android-sdk-linux/tools
# this next line installs every android thing ever, it's probably worth it to look at
# http://stackoverflow.com/questions/4681697/is-there-a-way-to-automate-the-android-sdk-installation
# to figure out how to reduce the crap it pulls in
#RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter platform-tools
#RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter tool
#RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter extra
#RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter android-17
#RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter android-18
#RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter android-19
#RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter android-20
RUN curl ${NDK_URL} > /root/android-tools/android-ndk.tar.bz2
RUN tar -xf android-ndk.tar.bz2 -C /root/android-tools/android-ndk-linux
RUN rm android-ndk.tar.bz2
ENV PATH $PATH:/root/android-tools/android-ndk-linux
RUN echo "export NDK_ROOT_DIR_ARM=/root/android-tools/android-ndk-linux" > /root/libretro-super/libretro-config-user.sh

# TODO: get android build working with ccache

WORKDIR /root/

#add the build script
ADD https://raw.githubusercontent.com/l3iggs/dockerfiles/master/libretro-linux-buildimage/lr-build.sh /bin/lr-build
RUN chmod a+x /bin/lr-build

# the commands above here set up the static image
# the commands below are executed with the docker run command
CMD lr-build
