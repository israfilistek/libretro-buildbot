#!/bin/bash -e

if [ -z "$MANIFEST_URL" ]; then
  echo "Updating code..."
else
  echo "Updating code using custom repositories..."
  mkdir -p /root/.repo/local_manifests
  curl $MANIFEST_URL > /root/.repo/local_manifests/my_manifest.xml
fi
cd /root/
repo sync
repo forall -c git submodule update --init

if [ $1 ]; then
  echo "Building $1..."
  cp /root/libretro-super/libretro-buildbot/build-now.sh /bin/build-now.sh
  chmod a+x /bin/build-now.sh $2
  build-now.sh $1
fi
