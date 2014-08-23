#this builds the frontend for windows
FROM libretro/arch-base:latest
MAINTAINER l3iggs <l3iggs@live.com>

# packages required to build the frontend for windows
RUN pacman -Suy --noconfirm mingw-w64-toolchain
RUN echo MAKEFLAGS="-j`nproc`" >> /etc/makepkg.conf

RUN mkdir /x264
WORKDIR /x264
RUN curl https://aur.archlinux.org/packages/mi/mingw-w64-x264/PKGBUILD > PKGBUILD
RUN sed -i 's,source=(git://git\.videolan\.org/x264\.git#commit=aff928d2),source=(git://git\.videolan\.org/x264\.git#commit=ea0ca51e94323318b95bd8b27b7f9438cdcf4d9e),g' PKGBUILD
RUN makepkg -s --asroot --noconfirm
RUN pacman -U --noconfirm mingw-w64-x264-*

RUN yaourt -Sa --noconfirm mingw-w64-libunistring
RUN yaourt -Sa --noconfirm mingw-w64-icu
RUN yaourt -Sa --noconfirm mingw-w64-gsm
RUN yaourt -Sa --noconfirm mingw-w64-lcms2
RUN yaourt -Sa --noconfirm mingw-w64-bzip2
RUN yaourt -Sa --noconfirm mingw-w64-crt
RUN yaourt -Sa --noconfirm mingw-w64-fontconfig
RUN yaourt -Sa --noconfirm mingw-w64-gnutls
RUN yaourt -Sa --noconfirm mingw-w64-lame
#RUN yaourt -Sa --noconfirm mingw-w64-libass
RUN yaourt -Sa --noconfirm mingw-w64-libbluray
RUN yaourt -Sa --noconfirm mingw-w64-libmodplug
RUN yaourt -Sa --noconfirm mingw-w64-libtheora
RUN yaourt -Sa --noconfirm mingw-w64-libvorbis
RUN yaourt -Sa --noconfirm mingw-w64-libvpx
RUN yaourt -Sa --noconfirm mingw-w64-opencore-amr
#RUN yaourt -Sa --noconfirm mingw-w64-openjpeg
RUN yaourt -Sa --noconfirm mingw-w64-opus
RUN yaourt -Sa --noconfirm mingw-w64-rtmpdump
RUN yaourt -Sa --noconfirm mingw-w64-schroedinger
RUN yaourt -Sa --noconfirm mingw-w64-sdl
RUN yaourt -Sa --noconfirm mingw-w64-speex
#mingw-w64-x264
RUN yaourt -Sa --noconfirm mingw-w64-x265
RUN yaourt -Sa --noconfirm mingw-w64-xvidcore
RUN yaourt -Sa --noconfirm mingw-w64-zlib
RUN yaourt -Sa --noconfirm mingw-w64-pkg-config
RUN pacman -Suy --noconfirm yasm

#RUN yaourt -Sa --noconfirm mingw-w64-x264
# ffmpeg currently won't compile because mingw-w64-icu won't, so I'm leaving ffmpeg out for now
RUN echo "[multilib]" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
RUN pacman -Suy --noconfirm
RUN yaourt -Sa --noconfirm mingw-w64-openjpeg
RUN yaourt -Sa --noconfirm mingw-w64-libass
RUN yaourt -Sa --noconfirm mingw-w64-ffmpeg
RUN yaourt -Sa --noconfirm mingw-w64-zlib mingw-w64-nvidia-cg-toolkit mingw-w64-freetype mingw-w64-sdl mingw-w64-sdl2 mingw-w64-libxml2

# ffmpeg currently won't compile because mingw-w64-icu won't, so I'm leaving ffmpeg out for now
WORKDIR /
RUN yaourt -Sa --noconfirm mingw-w64-pkg-config mingw-w64-clang
RUN pacman -Qdtq
#RUN fdsafasd

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
