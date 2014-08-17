#!/bin/bash -e

TODAY_IS=`date +"%Y-%m-%d"`

# ensure the image is up to date
docker pull l3iggs/android-builder

# run the build
docker run --cpuset="0,1,2" l3iggs/android-builder

rm -rf /home/buildbot/staging
docker cp $(docker ps -l -q):/staging /home/buildbot/
mkdir -p /home/buildbot/staging/android/build-logs/
docker logs $(docker ps -l -q) > /home/buildbot/staging/android/build-logs/build.log 2>&1

ALL_CORES=`find /home/buildbot/staging/ -name *.so`
for c in $ALL_CORES
do
  PARENT=`dirname $c`
  CORE_NAME=`basename $c`
  CORE_FOLDER=${PARENT}/${CORE_NAME%%.*}
  mkdir ${CORE_FOLDER}
  mv $c ${CORE_FOLDER}
done

ALL_FILES=`find /home/buildbot/staging/ -type f`
for f in $ALL_FILES
do
  PARENT=`dirname $f`
  FILE_NAME=`basename $f`
  mv $f ${PARENT}/${TODAY_IS}_${FILE_NAME}
done

mkdir -p /home/buildbot/www/nightly/
cp -r  /home/buildbot/staging/* /home/buildbot/www/nightly/
