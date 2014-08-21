#!/bin/bash -e

echo "Updating code..."
cd /root/
repo sync
repo forall -c git submodule update --init

/root/libretro-super/libretro-buildbot/build-now.sh $1
