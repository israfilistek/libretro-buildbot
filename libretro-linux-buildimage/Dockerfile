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
WORKDIR /root/libretro-super/
RUN ./retroarch-build.sh
RUN ./libretro-build.sh 
RUN mkdir -p /output/cores
WORKDIR /root/libretro-super/retroarch/
RUN make DESTDIR=/output install
WORKDIR /root/libretro-super/
RUN ./libretro-install.sh /output/cores
WORKDIR /output
RUN 7za a -r retroarch-linux.7z .

#the following is executed with the `docker run` command. it freshens the source code, cleans and builds from scratch.
#for a faster incrimental (delta) build use `docker run --env NOCLEAN=1`
CMD cd / && \
rm -rf /output && \
mkdir -p /output/cores && \
cd /root/ && \
repo sync && \
repo forall -c git submodule update --init && \
cd /root/libretro-super/ && \
./retroarch-build.sh && \
./libretro-build.sh && \
./libretro-install.sh /output/cores && \
cd /root/libretro-super/retroarch/ && \
make DESTDIR=/output install && \
cd /output && \
7za a -r retroarch-linux.7z .
