#!/bin/bash -e
# this script lives in the webserver and triggers the linux cores build and
# readies the files it generates for http consumption

TODAY_IS=`date +"%Y-%m-%d"`
LOG_NAME=build

#these strings must match the names of the repos in registry.hub.docker.com (prefixed with "libretro/build-linux-")
#declare -a DISTROS=("arch_linux" "ubuntu_14.04" "fedora_20")
declare -a DISTROS=("arch_linux")


for DISTRO in "${DISTROS[@]}"
  do
  # ensure the image is up to date
  docker pull libretro/build-linux-${DISTRO}

  # run the build
  docker run --cpuset="0,1,2" libretro/build-linux-${DISTRO}

  rm -rf /home/buildbot/staging
  docker cp $(docker ps -l -q):/staging /home/buildbot/
  mkdir -p /home/buildbot/staging/linux/build-logs/${DISTRO}
  docker logs $(docker ps -l -q) > /home/buildbot/staging/linux/build-logs/${DISTRO}/${LOG_NAME}.txt 2>&1
  cat -n /home/buildbot/staging/linux/build-logs/${DISTRO}/${LOG_NAME}.txt > /home/buildbot/staging/linux/build-logs/${DISTRO}/${LOG_NAME}_num.txt
  mv /home/buildbot/staging/linux/build-logs/${DISTRO}/${LOG_NAME}_num.txt /home/buildbot/staging/linux/build-logs/${DISTRO}/${LOG_NAME}.txt

  rm `find /home/buildbot/staging/ -name *.info`
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
    ln -sf ./${TODAY_IS}_${FILE_NAME} ${PARENT}/latest_${FILE_NAME}
  done
done
mkdir -p /home/buildbot/www/nightly/
cp -r  /home/buildbot/staging/* /home/buildbot/www/nightly/
