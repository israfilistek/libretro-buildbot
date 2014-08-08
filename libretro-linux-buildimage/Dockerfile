FROM ubuntu:14.04
MAINTAINER l3iggs <l3iggs@live.com>
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository multiverse
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get install -y git python curl p7zip-full
RUN git config --global user.email "buildbot@libretro.org"
RUN git config --global user.name "Build Bot"
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo
RUN chmod a+x /bin/repo
RUN apt-get install -y build-essential pkg-config libcggl libegl1-mesa-dev libasound2-dev libsdl1.2-dev libavformat-dev libavcodec-dev libswscale-dev libgbm-dev libxml2-dev libopenvg1-mesa-dev libv4l-dev libfreetype6-dev libxv-dev libxinerama-dev python3-dev nvidia-cg-toolkit libavdevice-dev libavresample-dev libass-dev libxkbcommon-dev
WORKDIR /root/
RUN repo init -u https://github.com/libretro/libretro-manifest.git
RUN repo sync
RUN repo forall -c git submodule update --init

#above here is all cached. below gets run every time the image is rebuilt to ensure it stays fresh. this is a complete rebuild
ONBUILD RUN apt-get update
ONBUILD RUN apt-get -y dist-upgrade
ONBUILD RUN repo sync
ONBUILD RUN repo forall -c git submodule update --init
ONBUILD WORKDIR /root/libretro-super/
ONBUILD RUN ./retroarch-build.sh
ONBUILD RUN ./libretro-build.sh
ONBUILD RUN mkdir -p /output/cores
ONBUILD WORKDIR /root/libretro-super/retroarch/
ONBUILD RUN make DESTDIR=/output install
ONBUILD WORKDIR /root/libretro-super/
ONBUILD RUN ./libretro-install.sh /output/cores
ONBUILD WORKDIR /output
ONBUILD RUN 7za a -r retroarch-linux.7z .

#this gets executed with the `docker run` command. it freshens the source code to the latest and does an incrimental build on that
CMD cd / && \
rm -rf /output && \
mkdir -p /output/cores && \
cd /root/ && \
repo sync && \
repo forall -c git submodule update --init && \
cd /root/libretro-super/ && \
NOCLEAN=1 ./retroarch-build.sh && \
NOCLEAN=1 ./libretro-build.sh && \
./libretro-install.sh /output/cores && \
cd /root/libretro-super/retroarch/ && \
make DESTDIR=/output install && \
cd /output && \
7za a -r retroarch-linux.7z .
