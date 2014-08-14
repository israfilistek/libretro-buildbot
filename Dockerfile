# this builds the frontend for ubuntu 13.04
FROM ubuntu:13.04
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository multiverse
RUN apt-get update
RUN apt-get -y dist-upgrade

# setup repo
RUN apt-get install -y python git
RUN git config --global user.email "buildbot@libretro.com"
RUN git config --global user.name "Build Bot"
ADD https://storage.googleapis.com/git-repo-downloads/repo /bin/repo
RUN chmod a+x /bin/repo

# get the source code
WORKDIR /root/
RUN repo init -u https://github.com/libretro/libretro-manifest.git
RUN repo sync
RUN repo forall -c git submodule update --init

#setup ccache
RUN apt-get install -y ccache
RUN mkdir /ccache
ENV CCACHE_DIR /ccache
ENV PATH /usr/lib/ccache/bin:$PATH
RUN ccache -M 6

# all the front-end dependancies
RUN apt-get install -y build-essential pkg-config libcggl libegl1-mesa-dev libasound2-dev libsdl2-dev libsdl1.2-dev libavformat-dev libavcodec-dev libswscale-dev libgbm-dev libxml2-dev libopenvg1-mesa-dev libv4l-dev libfreetype6-dev libxv-dev libxinerama-dev python3-dev nvidia-cg-toolkit libavdevice-dev libavresample-dev libass-dev libxkbcommon-dev

# for working in the image
RUN apt-get install -y vim

# for packaging outputs
RUN apt-get install -y p7zip-full

#add the build script
ADD https://raw.githubusercontent.com/l3iggs/libretro-buildbot/master/nightly-build.sh /bin/nightly-build
RUN chmod a+x /bin/nightly-build

# build once now to populate ccache
RUN nightly-build linux_retroarch

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
CMD nightly-build linux_retroarch
