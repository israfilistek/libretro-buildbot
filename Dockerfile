FROM libretro/arch-base
MAINTAINER l3iggs <l3iggs@live.com>

# set number of build cores for yaourt builds
RUN echo MAKEFLAGS="-j`nproc`" >> /etc/makepkg.conf

# enable multilib
RUN echo "[multilib]" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
RUN pacman -Suy --noconfirm

#install ffmpeg
RUN yaourt -Suya --noconfirm --needed mingw-w64-ffmpeg
# remove unneeded packages
# RUN pacman -Rsn --noconfirm $(pacman -Qdtq)

# disable multilib
RUN head -n -2 /etc/pacman.conf > /etc/pacman.conf.new && mv /etc/pacman.conf.
new /etc/pacman.conf
RUN pacman -Suy --noconfirm

# packages required to build the frontend and cores for windows
RUN pacman -Suy --noconfirm mingw-w64
RUN yaourt -Suya --noconfirm --needed mingw-w64-zlib mingw-w64-nvidia-cg-toolkit mingw-w64-freetype mingw-w64-sdl mingw-w64-sdl2 mingw-w64-libxml2
RUN yaourt -Suya --noconfirm --needed mingw-w64-pkg-config mingw-w64-clang
#RUN pacman -Rsn --noconfirm $(pacman -Qdtq)

# unset number of cores in makepkg
RUN head -n -1 /etc/makepkg.conf > /etc/makepkg.conf.new && mv /etc/makepkg.conf.new /etc/makepkg.conf

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
RUN cd /root/ && yes | repo init -u https://github.com/libretro/libretro-manifest.git

# add the bootstrap script
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/master/bootstrap.sh /bin/bootstrap.sh
RUN chmod a+x /bin/bootstrap.sh

# build once now to fetch code and populate ccache
RUN bootstrap.sh windows_all

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
CMD bootstrap.sh windows_all
