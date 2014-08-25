#!/bin/bash -e
# this script lives in the webserver and triggers the RetroArch build for Fedora 20
# and readies the files it generates for http consumption

TODAY_IS=`date +"%Y-%m-%d"`
LOG_NAME=build

# ensure the image is up to date
docker pull libretro/win-builder

# run the build
docker run --cpuset="0,1,2" libretro/win-builder

rm -rf /home/buildbot/staging
docker cp $(docker ps -l -q):/staging /home/buildbot/

mkdir -p /home/buildbot/staging/windows/build-logs/
docker logs $(docker ps -l -q) | curl -XPOST http://hastebin.com/documents --data-binary @- > /home/buildbot/staging/linux/build-logs/${LOG_NAME}.html
sed -i 's,{"key":",<meta http-equiv="refresh" content="0; url=http://hastebin.com/,g' /home/buildbot/staging/linux/build-logs/${LOG_NAME}.html
sed -i 's,"}," />,g' /home/buildbot/staging/linux/build-logs/${LOG_NAME}.html

rm `find /home/buildbot/staging/ -name *.info`
ALL_CORES=`find /home/buildbot/staging/ -name *.dll`
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
  ln -sf ./${TODAY_IS}_${FILE_NAME} ${PARENT}/latest_${FILE_NAME}
done

mkdir -p /home/buildbot/www/nightly/
cp -r  /home/buildbot/staging/* /home/buildbot/www/nightly/
