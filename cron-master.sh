#!/bin/bash
# this is the script that gets called by cron on the build machine/web host
# the following line goes into crontab (change frequency as desired):
# @daily curl https://raw.githubusercontent.com/libretro/libretro-buildbot/master/cron-master.sh > /home/buildbot/cron-master.sh; chmod a+x /home/buildbot/cron-master.sh; /home/buildbot/cron-master.sh;
# ^^ this *should be* the only manual step required to installing this buildbot
# everything else *shoudld be* automated and self-updating from code in this repository
# this requires that there is a directroy /home/buildbot and the caller
# has write access to that directory and can use the docker command

# these should be names of scripts in https://github.com/libretro/libretro-buildbot/tree/master
declare -a BUILD_SCRIPTS=("cron-android-build.sh" "cron-linux-core-build.sh" "cron-wondows-core-build.sh")

# for each script, make sure it's up to date from the repo and then run it
for s in "${BUILD_SCRIPTS[@]}"
do
  curl https://raw.githubusercontent.com/libretro/libretro-buildbot/master/${s} > /home/buildbot/${s}
  chmod a+x /home/buildbot/${s}
  /home/buildbot/${s}
done

# let's clean up docker
echo "Cleaning up unneeded docker images."
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker images | grep '<none>' |  awk '{print $3}'  | xargs docker rmi || echo "No docker cleaning needed."
