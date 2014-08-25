#!/bin/bash -e
# this script lives in the webserver and triggers the RetroArch build for Fedora 20
# and readies the files it generates for http consumption

TODAY_IS=`date +"%Y-%m-%d"`
LOG_NAME=retroarch_fedora20

# ensure the image is up to date
docker pull libretro/retroarch-fedora20-builder

# run the build
docker run --cpuset="0,1,2" libretro/retroarch-fedora20-builder

rm -rf /home/buildbot/staging
docker cp $(docker ps -l -q):/staging /home/buildbot/

shopt -s globstar
for dir in /home/buildbot/staging/linux/*/; do
  mkdir ${dir}/RetroArch/Fedora20
  mv ${dir}/RetroArch.7z ${dir}/RetroArch/Fedora20/
done

mkdir -p /home/buildbot/staging/linux/build-logs/
docker logs $(docker ps -l -q) | curl -XPOST http://hastebin.com/documents --data-binary @- > /home/buildbot/staging/linux/build-logs/${LOG_NAME}.html
sed -i 's,{"key":",<meta http-equiv="refresh" content="0; url=http://hastebin.com/,g' /home/buildbot/staging/linux/build-logs/${LOG_NAME}.html
sed -i 's,"}," />,g' /home/buildbot/staging/linux/build-logs/${LOG_NAME}.html
#docker logs $(docker ps -l -q) > /home/buildbot/staging/linux/build-logs/${LOG_NAME} 2>&1
#cat -n /home/buildbot/staging/linux/build-logs/${LOG_NAME} > /home/buildbot/staging/linux/build-logs/${LOG_NAME}_num.txt
#mv /home/buildbot/staging/linux/build-logs/${LOG_NAME}_num.txt /home/buildbot/staging/linux/build-logs/${LOG_NAME}

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
