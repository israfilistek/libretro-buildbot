# this builds the cores for windows
FROM libretro/arch-base:latest
MAINTAINER l3iggs <l3iggs@live.com>

# packages required to build cores for windows
RUN pacman -Suy --noconfirm mingw-w64-toolchain

# for working in the image
RUN pacman -Suy --noconfirm vim

# for packaging outputs
RUN pacman -Suy --noconfirm p7zip

# setup repo for this project
RUN cd /root/ && repo init -u https://github.com/libretro/libretro-manifest.git

#RUN cd /root/ && repo sync
#RUN cd /root/ && repo forall -c git submodule update --init

# add the build script
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/master/build-now.sh /bin/build-now.sh

# build once now to populate ccache
RUN build-now.sh windows_cores

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
CMD build-now.sh windows_cores
