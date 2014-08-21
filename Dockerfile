# this builds the frontend for Fedora Rawhide
FROM fedora:rawhide
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment
RUN yum install -y deltarpm
RUN yum localinstall -y --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
RUN yum distro-sync -y --nogpgcheck full

# setup repo
RUN yum install --nogpgcheck -y python python-gnupg git
RUN git config --global user.email "buildbot@none.com"
RUN git config --global user.name "Build Bot"
ADD https://storage.googleapis.com/git-repo-downloads/repo /bin/repo
RUN chmod a+x /bin/repo

# setup ccache
RUN yum install --nogpgcheck -y ccache
RUN mkdir /ccache
ENV CCACHE_DIR /ccache
RUN cp /usr/bin/ccache /usr/local/bin/
RUN ln -s ccache /usr/local/bin/gcc
RUN ln -s ccache /usr/local/bin/g++
RUN ln -s ccache /usr/local/bin/cc
RUN ln -s ccache /usr/local/bin/c++
RUN ccache -M 6

# all the front-end dependancies
RUN yum install --nogpgcheck -y make automake clang gcc gcc-c++ mesa-libEGL-devel libv5l-devel libxkbcommon-devel mesa-libgbm-devel Cg libCg zlib-devel freetype-devel libxml2-devel ffmpeg-devel SDL2-devel SDL-devel python3-devel libXv-devel

# setup repo for this project
RUN cd /root/ && repo init -u https://github.com/libretro/libretro-manifest.git

# add the build script
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/master/build-now.sh /bin/build-now.sh
RUN chmod a+x /bin/build-now.sh

# for packaging outputs
RUN yum install --nogpgcheck -y p7zip

# for working in the image
RUN yum install --nogpgcheck -y vim

# build once now to populate ccache
RUN build-now.sh linux_retroarch

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
CMD build-now.sh linux_retroarch
