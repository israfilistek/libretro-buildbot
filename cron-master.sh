#!/bin/bash
# this is the script that gets called by cron on the build machine/web host
# the following line goes into crontab (change frequency as desired):
# @daily curl https://raw.githubusercontent.com/libretro/libretro-buildbot/master/cron-master.sh > /home/buildbot/cron-master.sh; chmod a+x /home/buildbot/cron-master.sh; /home/buildbot/cron-master.sh;
# ^^ this *should be* the only manual step required to installing this buildbot
# everything else *shoudld be* automated and self-updating from code in this repository
# the scrips herin are all hardcoded to assume that there is a directroy /home/buildbot
# and that output binaries should go into /home/buildbot/www
# it also assumes the caller has write access to that directory and can use the docker command

# this list defines the list of things that get done when the build bot is fired off by cron
# these should be names of scripts in https://github.com/libretro/libretro-buildbot/tree/master
declare -a BUILD_SCRIPTS=("cron-linux-build.sh" "cron-android-build.sh" "cron-windows-build.sh")

# for each script, make sure it's up to date from the repo and then run it
for s in "${BUILD_SCRIPTS[@]}"
do
  curl https://raw.githubusercontent.com/libretro/libretro-buildbot/master/${s} > /home/buildbot/${s}
  chmod a+x /home/buildbot/${s}
  /home/buildbot/${s}
done

# docker cleanup (if you're not careful, docker loves to eat disk space)
echo "Cleaning up unneeded docker images."
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker images | grep '<none>' |  awk '{print $3}'  | xargs docker rmi || echo "No docker cleaning needed."
