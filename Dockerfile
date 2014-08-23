#this is the mess that crosscompiles ffmpeg for windows
FROM libretro/arch-base:latest
MAINTAINER l3iggs <l3iggs@live.com>

# packages required to build the frontend for windows
RUN pacman -Suy --noconfirm mingw-w64-toolchain
RUN echo MAKEFLAGS="-j`nproc`" >> /etc/makepkg.conf

RUN yaourt -Sa --noconfirm --needed mingw-w64-gsm
RUN yaourt -Sa --noconfirm --needed mingw-w64-fontconfig
RUN yaourt -Sa --noconfirm --needed mingw-w64-lcms2

RUN mkdir /x264
WORKDIR /x264
RUN curl https://aur.archlinux.org/packages/mi/mingw-w64-x264/PKGBUILD > PKGBUILD
RUN sed -i 's,source=(git://git\.videolan\.org/x264\.git#commit=aff928d2),source=(git://git\.videolan\.org/x264\.git#commit=ea0ca51e94323318b95bd8b27b7f9438cdcf4d9e),g' PKGBUILD
RUN makepkg -s --asroot --noconfirm
RUN pacman -U --noconfirm mingw-w64-x264-*
WORKDIR /

RUN yaourt -Sa --noconfirm --needed mingw-w64-libunistring
RUN yaourt -Sa --noconfirm --needed mingw-w64-icu
RUN yaourt -Sa --noconfirm --needed mingw-w64-bzip2
RUN yaourt -Sa --noconfirm --needed mingw-w64-crt
RUN yaourt -Sa --noconfirm --needed mingw-w64-gnutls
RUN yaourt -Sa --noconfirm --needed mingw-w64-lame
#RUN yaourt -Sa --noconfirm --needed mingw-w64-libass
RUN yaourt -Sa --noconfirm --needed mingw-w64-libbluray
RUN yaourt -Sa --noconfirm --needed mingw-w64-libmodplug
RUN yaourt -Sa --noconfirm --needed mingw-w64-libtheora
RUN yaourt -Sa --noconfirm --needed mingw-w64-libvorbis
RUN yaourt -Sa --noconfirm --needed mingw-w64-libvpx
RUN yaourt -Sa --noconfirm --needed mingw-w64-opencore-amr
#RUN yaourt -Sa --noconfirm --needed mingw-w64-openjpeg
RUN yaourt -Sa --noconfirm --needed mingw-w64-opus
RUN yaourt -Sa --noconfirm --needed mingw-w64-rtmpdump
RUN yaourt -Sa --noconfirm --needed mingw-w64-schroedinger
RUN yaourt -Sa --noconfirm --needed mingw-w64-sdl
RUN yaourt -Sa --noconfirm --needed mingw-w64-speex
#mingw-w64-x264
RUN yaourt -Sa --noconfirm --needed mingw-w64-x265
RUN yaourt -Sa --noconfirm --needed mingw-w64-xvidcore
RUN yaourt -Sa --noconfirm --needed mingw-w64-zlib
RUN yaourt -Sa --noconfirm --needed mingw-w64-pkg-config
RUN pacman -Suy --noconfirm --needed yasm

#RUN yaourt -Sa --noconfirm mingw-w64-x264

RUN echo "[multilib]" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
RUN pacman -Suy --noconfirm
RUN yaourt -Sa --noconfirm --needed mingw-w64-openjpeg
RUN yaourt -Sa --noconfirm --needed mingw-w64-libass
RUN yaourt -Sa --noconfirm --needed mingw-w64-ffmpeg
