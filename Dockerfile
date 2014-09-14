#this is the Arch Linux base
FROM base/devel:latest
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment
RUN pacman -Suy --noconfirm
RUN git config --global user.email "buildbot@none.com"
RUN git config --global user.name "Build Bot"

# install repo tool
RUN yaourt -Suya --noconfirm --needed repo

# setup ccache
RUN pacman -Suy --noconfirm ccache
RUN mkdir /ccache
ENV CCACHE_DIR /ccache
ENV PATH /usr/lib/ccache/bin:$PATH
RUN ccache -M 6

#update all the packages every time this is used in a build downstream
ONBUILD RUN pacman -Suy --noconfirm
