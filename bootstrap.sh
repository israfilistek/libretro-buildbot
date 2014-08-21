#!/bin/bash -e

echo "Updating code..."
cd /root/
repo sync
repo forall -c git submodule update --init

cp /root/libretro-super/libretro-buildbot/build-now.sh /bin/build-now.sh
chmod a+x /bin/build-now.sh

build-now.sh $1
