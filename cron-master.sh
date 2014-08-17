#!/bin/bash
# this is the script that gets called by cron on the build machine/web host

# these should be names of scripts in https://github.com/libretro/libretro-buildbot/tree/master
declare -a BUILD_SCRIPTS=("cron-android-build.sh" "cron-linux-core-build.sh")

# for each script, make sure it's up to date from the repo and then run it
for s in "${BUILD_SCRIPTS[@]}"
do
  curl https://raw.githubusercontent.com/libretro/libretro-buildbot/master/${s} > /home/buildbot/${s}
  chmod a+x /home/buildbot/${s}
  /home/buildbot/${s}
done
