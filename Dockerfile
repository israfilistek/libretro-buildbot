# this builds the frontend for windows
FROM libretro/arch-base:latest
MAINTAINER l3iggs <l3iggs@live.com>

# packages required to build the frontend for windows
RUN pacman -Suy --noconfirm mingw-w64-toolchain python
RUN yaourt -Sa --noconfirm mingw-w64-zlib mingw-w64-nvidia-cg-toolkit mingw-w64-freetype mingw-w64-sdl mingw-w64-sdl2 mingw-w64-libxml2 mingw-w64-pkg-config mingw-w64-clang
RUN yaourt -Sa --noconfirm mingw-w64-lame
RUN yaourt -Sa --noconfirm mingw-w64-ffmpeg

# for working in the image
RUN pacman -Suy --noconfirm vim

# for packaging outputs
RUN pacman -Suy --noconfirm p7zip zip

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
