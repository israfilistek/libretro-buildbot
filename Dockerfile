# this builds the frontend for windows
FROM libretro/arch-base:latest
MAINTAINER l3iggs <l3iggs@live.com>

# packages required to build the frontend for windows
RUN pacman -Suy --noconfirm mingw-w64-toolchain python
RUN yaourt -Sa --noconfirm mingw-w64-zlib mingw-w64-nvidia-cg-toolkit mingw-w64-freetype mingw-w64-sdl mingw-w64-sdl2 mingw-w64-libxml2

#maybe one day this will work, but today it doesn't so i'm commenting it out
#RUN yaourt -Sa --noconfirm mingw-w64-ffmpeg

# setup ccache for this toolchain
RUN cp /usr/bin/ccache /usr/local/bin/
RUN ln -s ccache /usr/local/bin/i686-w64-mingw32-gcc
RUN ln -s ccache /usr/local/bin/i686-w64-mingw32-g++
RUN ln -s ccache /usr/local/bin/i686-w64-mingw32-cc
RUN ln -s ccache /usr/local/bin/i686-w64-mingw32-c++
RUN ln -s ccache /usr/local/bin/x86_64-w64-mingw32-gcc
RUN ln -s ccache /usr/local/bin/x86_64-w64-mingw32-g++
RUN ln -s ccache /usr/local/bin/x86_64-w64-mingw32-cc
RUN ln -s ccache /usr/local/bin/x86_64-w64-mingw32-c++

# for working in the image
RUN pacman -Suy --noconfirm vim

# for packaging outputs
RUN pacman -Suy --noconfirm p7zip zip

# setup repo for this project
RUN cd /root/ && repo init -u https://github.com/libretro/libretro-manifest.git

# add the bootstrap script
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/master/bootstrap.sh /bin/bootstrap.sh
RUN chmod a+x /bin/bootstrap.sh

# build once now to populate ccache
RUN bootstrap.sh windows_frontend

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
CMD bootstrap.sh windows_frontend
