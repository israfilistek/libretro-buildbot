#this is the Arch Linux base
FROM base/devel:latest
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment, grab the source code
RUN pacman -Suy --noconfirm p7zip vim python2 ccache
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
RUN pacman -Suy --noconfirm nvidia-cg-toolkit mesa-libgl sdl ffmpeg libxkbcommon libxinerama libxv python glu clang

# build once for linux x86_64 to populate ccache
WORKDIR /root/libretro-super/
RUN ./retroarch-build.sh
RUN ./libretro-build.sh

# win x86_64 setup section
RUN pacman -Suy --noconfirm mingw-w64-toolchain zip unzip wget

# Android setup section
RUN pacman -Suy --noconfirm apache-ant
#TODO: create the apk signing key store here

WORKDIR /root/

#add the build script
ADD https://raw.githubusercontent.com/l3iggs/dockerfiles/master/libretro-linux-buildimage/lr-build.sh /bin/lr-build
RUN chmod a+x /bin/lr-build

# the commands above here set up the static image
# the commands below are executed with the docker run command
CMD lr-build
