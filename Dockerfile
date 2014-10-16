##this prepares the android build environment
FROM libretro/arch-base:latest
MAINTAINER l3iggs <l3iggs@live.com>

# need to be able to install/run some 32bit components for some SDK pieces
RUN echo "[multilib]" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

# Install Android SDK
RUN yaourt -Suya --noconfirm --needed android-sdk android-sdk-build-tools

# Install Android NDK (might need to add `--tmp /var/tmp` here on ram constrained boxes)
RUN yaourt -Sya --noconfirm --needed android-ndk32 android-ndk64

# standalone NDK32
ENV NDK32_STANDALONE /opt/ndk32-standalone-toolchain
RUN mkdir ${NDK32_STANDALONE}
RUN /opt/android-ndk32/build/tools/make-standalone-toolchain.sh --platform=android-9 --toolchain=arm-linux-androideabi-4.8 --install-dir=${NDK32_STANDALONE}
# --toolchain here should be one of: arm-linux-androideabi-4.6 arm-linux-androideabi-4.8 arm-linux-androideabi-clang3.3 arm-linux-androideabi-clang3.4 llvm-3.3 llvm-3.4 mipsel-linux-android-4.6 mipsel-linux-android-4.8 mipsel-linux-android-clang3.3 mipsel-linux-android-clang3.4 renderscript x86-4.6 x86-4.8 x86-clang3.3 x86-clang3.4

# standalone NDK64
ENV NDK64_STANDALONE /opt/ndk64-standalone-toolchain
RUN mkdir ${NDK64_STANDALONE}
RUN /opt/android-ndk64/build/tools/make-standalone-toolchain.sh --platform=android-L --toolchain=x86_64-4.9  --install-dir=${NDK64_STANDALONE}
# --toolchain here should be one of: aarch64-linux-android-4.9 aarch64-linux-android-clang3.4 arm-linux-androideabi-4.9 llvm-3.4 mips64el-linux-android-4.9 mips64el-linux-android-clang3.4 mipsel-linux-android-4.9 x86-4.9 x86_64-4.9 x86_64-clang3.4

# Install Android target development platform(s)
RUN yaourt -Suya --noconfirm --needed android-platform-18

# Install other misc Android build reqs
RUN pacman -Suy --noconfirm apache-ant python3 nvidia-cg-toolkit

# for working in the image
RUN pacman -Suy --noconfirm vim

# for packaging outputs
RUN pacman -Suy --noconfirm p7zip zip

# enable ccache for NDK builds
ENV NDK_CCACHE ccache

# setup repo for this project
RUN cd /root/ && repo init -u https://github.com/libretro/libretro-manifest.git

# add the bootstrap script
ADD https://raw.githubusercontent.com/libretro/libretro-buildbot/master/bootstrap.sh /bin/bootstrap.sh
RUN chmod a+x /bin/bootstrap.sh

# build once now to populate ccache
RUN bootstrap.sh android

# the commands above here set up the static image
# the command below here gets executed by default when the container is "run" with the `docker run` command
ENTRYPOINT ["bootstrap.sh", "android"]
