# this builds the frontend for ubuntu 13.04
FROM ubuntu:13.04
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment
RUN echo deb http://archive.ubuntu.com/ubuntu/ raring multiverse >> /etc/apt/sources.list
RUN echo deb http://archive.ubuntu.com/ubuntu/ raring-updates multiverse >> /etc/apt/sources.list
RUN sed -i 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y dist-upgrade

# setup repo
RUN apt-get install -y python git
RUN git config --global user.email "buildbot@libretro.com"
RUN git config --global user.name "Build Bot"
ADD https://storage.googleapis.com/git-repo-downloads/repo /bin/repo
RUN chmod a+x /bin/repo

# setup ccache
RUN apt-get install -y ccache
RUN mkdir /ccache
ENV CCACHE_DIR /ccache
RUN cp /usr/bin/ccache /usr/local/bin/
RUN ln -s ccache /usr/local/bin/gcc
RUN ln -s ccache /usr/local/bin/g++
RUN ln -s ccache /usr/local/bin/cc
RUN ln -s ccache /usr/local/bin/c++
RUN ccache -M 6

# all the front-end dependancies
RUN apt-get install -y build-essential pkg-config libcggl libegl1-mesa-dev libasound2-dev libsdl1.2-dev libavformat-dev libavcodec-dev libswscale-dev libgbm-dev libxml2-dev libopenvg1-mesa-dev libv4l-dev libfreetype6-dev libxv-dev libxinerama-dev python3-dev nvidia-cg-toolkit libavdevice-dev libass-dev libxkbcommon-dev libwayland-dev

# setup repo for this project
RUN cd /root/ && repo init -u https://github.com/libretro/libretro-manifest.git

# add the build script
ADD https://raw.githubusercontent.com/l3iggs/libretro-buildbot/master/build-now.sh /bin/build-now.sh
RUN chmod a+x /bin/build-now.sh

# for packaging outputs
RUN apt-get install -y p7zip-full

# for working in the image
RUN apt-get install -y vim

# build once now to populate ccache
RUN build-now.sh linux_retroarch

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
CMD build-now.sh linux_retroarch
