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