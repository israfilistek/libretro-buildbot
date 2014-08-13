# this builds the frontend for ubuntu 13.04
FROM ubuntu:14.04
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment, grab the source code
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository multiverse
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN git config --global user.email "buildbot@libretro.com"
RUN git config --global user.name "Build Bot"

# get the source code
WORKDIR /root/
RUN repo init -u https://github.com/libretro/libretro-manifest.git
RUN repo sync
RUN repo forall -c git submodule update --init

# all the front-end dependancies
RUN apt-get install -y build-essential pkg-config libcggl libegl1-mesa-dev libasound2-dev libsdl2-dev libsdl1.2-dev libavformat-dev libavcodec-dev libswscale-dev libgbm-dev libxml2-dev libopenvg1-mesa-dev libv4l-dev libfreetype6-dev libxv-dev libxinerama-dev python3-dev nvidia-cg-toolkit libavdevice-dev libavresample-dev libass-dev libxkbcommon-dev

# build the front end
WORKDIR /root/libretro-super/
RUN ./retroarch-build.sh

# for working in the image
RUN apt-get install -y vim

# for packaging outputs
RUN apt-get install -y p7zip-full

WORKDIR /root/

#add the build script
ADD https://raw.githubusercontent.com/l3iggs/libretro-buildbot/master/nightly-build.sh /bin/nightly-build
RUN chmod a+x /bin/nightly-build

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
CMD nightly-build linux_x86_64
