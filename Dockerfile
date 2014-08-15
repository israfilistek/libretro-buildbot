# this builds the frontend for Arch Linux
FROM l3iggs/arch-base:latest
MAINTAINER l3iggs <l3iggs@live.com>

# packages required to build for linux x86_64
RUN pacman -Suy --noconfirm nvidia-cg-toolkit mesa-libgl sdl sdl2 ffmpeg libxkbcommon libxinerama libxv python glu clang

# for working in the image
RUN pacman -Suy --noconfirm vim

# for packaging outputs
RUN pacman -Suy --noconfirm p7zip

# setup repo for this project
RUN cd /root/ && repo init -u https://github.com/libretro/libretro-manifest.git

# add the build script
ADD https://raw.githubusercontent.com/l3iggs/libretro-buildbot/master/nightly-build.sh /bin/nightly-build
RUN chmod a+x /bin/nightly-build

# build once now to populate ccache
RUN nightly-build linux_retroarch

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
CMD nightly-build linux_retroarch
