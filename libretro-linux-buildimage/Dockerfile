 #this is the Arch Linux base
FROM base/devel:latest
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment, grab the source code
RUN pacman -Suy --noconfirm p7zip vim python2 ccache
RUN mkdir /ccache
ENV CCACHE_DIR /ccache
ENV PATH /usr/lib/ccache/bin:$PATH
RUN ccache -M 6
RUN git config --global user.email "buildbot@libretro.org"
RUN git config --global user.name "Build Bot"
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo
RUN sed -i 's/python/python2/g' /bin/repo
RUN chmod a+x /bin/repo
WORKDIR /root/
RUN repo init -u https://github.com/libretro/libretro-manifest.git
RUN repo sync
RUN repo forall -c git submodule update --init
WORKDIR /root/libretro-super/

# packages required to build for linux x86_64
RUN pacman -Suy --noconfirm nvidia-cg-toolkit mesa-libgl sdl ffmpeg libxkbcommon libxinerama libxv python glu clang

# packages required to build for win x86_64
RUN pacman -Suy --noconfirm mingw-w64-toolchain zip unzip wget

# build once for linux x86_64 to populate ccache
RUN ./retroarch-build.sh
RUN ./libretro-build.sh

# create the output directories
RUN mkdir -p /output/linux/x86_64/cores
RUN mkdir -p /nightly/linux/x86_64
WORKDIR /root/

# the commands above here set up the static image
# the commands below are executed with the docker run command
CMD repo sync && \ddd
repo forall -c git submodule update --init && \
cd libretro-super && \
./retroarch-build.sh && \
./libretro-build.sh && \
./libretro-install.sh /output/linux/x86_64/cores && \
cd retroarch/ && \
make DESTDIR=/output/linux/x86_64 install && \
7za a -r /nightly/linux/x86_64/$(date +"%Y-%m-%d_%T")_retroarch-linux_x86_64.7z /output/linux_x86_64/*
