FROM base/devel:latest
MAINTAINER l3iggs <l3iggs@live.com>
RUN pacman -Suy --noconfirm p7zip vim python2 ccache
RUN mkdir /ccache
ENV PATH /usr/lib/ccache/bin:$PATH
ENV CCACHE_DIR /ccache
RUN ccache -M 6
RUN git config --global user.email "buildbot@libretro.org"
RUN git config --global user.name "Build Bot"
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo
RUN sed -i 's/python/python2/g' /bin/repo
RUN chmod a+x /bin/repo
RUN pacman -Suy --noconfirm nvidia-cg-toolkit mesa-libgl sdl ffmpeg libxkbcommon libxinerama libxv python glu clang
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
