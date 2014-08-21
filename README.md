libretro-buildbot
===========
This is a collection of Dockerfiles and scripts for libretro that define a set of nightly build bots. For completely automated and reoccurring builds, see installation comments in cron-master.sh

## Quick Usage
**Step 1**: [Install Docker](https://docs.docker.com/installation/)  
**Step 2**: Initate a build of some aspect of libretro:  
`docker run libretro/$PROJECT`  
Where $PROJECT is the name of one of the branches in this repository (other than master)  
**Step 3**: Copy whatever you just built out of the build container:  
`docker cp $(docker ps -l -q):/staging/ .`  
You'll now have a folder called "staging" in your current working directory that contains the binaries you just built.

## Details
This repository is split into several branches. Each branch (besides master) contains one Dockerfile that defines a specific image that is part of the automated build system. Each of the Dockerfiles/Branches in this repository describes how a Linux file system image built and hosted [here](https://registry.hub.docker.com/repos/libretro/) should be generated. These images are updated automatically with pushes to this repository.

To use any of these images to build libretro on your own computer you must have Docker installed. Docker is available for many different environments including Windows, OSX and many different Linux flavors. Currently, Docker only works on 64 bit systems. To install Docker, follow the instructions for your system [here](https://docs.docker.com/installation/)

You can now "run" one of the pre-made Docker containers to build some libretro binaries (see Step 2 above).

Note that the first time you run something like `docker run libretro/android-builder`, you'll initiate a large download (the images are hosted [here](https://registry.hub.docker.com/repos/libretro) before performing the build locally on your computer. This download may be on the order of 20GB (you're downloading the entire build invironment, all libretro code and all depenancies). This large download should only be needed once (parts of the image may have to be re-downloaded later if I need to update the build images in some way like add a dependancy or update a toolchain, to keep your image up-to-date run `docker pull $PROJECT`). Once you have the image, new builds are very fast because they've been previously cached with ccache and because you only have to fetch small delta updates to the codebase. Typically a complete rebuild of all cores from make clean should take 10-15 minutes on most computers (after the giant download completes). Build speed can be greatly increased by skipping the clean step. Do this by inserting `--env NOCLEAN=1` after your `docker run` command, but this might cause build errors.

Now that the binaries have been built, you must copy them out of the build environment. You can do this with the following command:  
`docker cp $(docker ps -l -q):/staging/ .`  
That copies the build output into your current working directory. 

### Using the buildbot in your developement workflow
Let's say you'd like to make a change to [RetroArch](https://github.com/libretro/RetroArch). Fork it to your own github account and create a new branch, "test-branch" and make whatever changes you'd like and commit & push them. Now you must formulate an xml file like this:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remove-project name="libretro/RetroArch"/>
  <remote fetch="https://github.com/l3iggs/" name="mygithub"/>
  <project name="RetroArch" path="libretro-super/retroarch" remote="mygithub" revision="test-branch" />
</manifest>
```
This disables the upstream RetroArch repo (libretro/RetroArch) and uses test-branch of your repo in place of it. Now paste this xml into http://pastebin.com/ and get the link to the raw paste you just created (the url will look something  like this if you've done it properly: http://pastebin.com/raw.php?i=2QDA3cqE) You can now issue, say  
```bash
docker run --env MANIFEST_URL=http://pastebin.com/raw.php?i=2QDA3cqE libretro/android-build
```  
to build the entire libretro project with your change and generate an .apk. Don't forget to `docker cp $(docker ps -l -q):/staging/ .` to extract your binaries from the build image.  
If you'd like to compile only one android core after your change, say dinothwar, then issue  
```bash
docker run --env MANIFEST_URL=http://pastebin.com/raw.php?i=2QDA3cqE libretro/android-build bootstrap.sh android_all build_libretro_dinothawr
```


### Take all projects back in time
If you wish to, say compile an android APK with the entire code base in some previous state that you can pick by date:
```bash
docker run -i -t libretro/android-builder /bin/bash  
cd /root
repo forall -c 'git checkout `git rev-list --all -n1 --before="2014-08-15 15:00"`'
/root/libretro-super/libretro-buildbot/build-now.sh android_all
exit
docker cp $(docker ps -l -q):/staging/ .
```
