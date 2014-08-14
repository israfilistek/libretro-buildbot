libretro-buildbot
===========
A collection of Dockerfiles and scripts for libretro that define a set of nightly build bots.

## Quick Usage
**Step 1**: [Install Docker](https://docs.docker.com/installation/)  
**Step 2**: Build something:  
`docker run --env NOCLEAN=1 l3iggs/$PROJECT`  
Where $PROJECT is the name of one of the branches in this repository (other than master)  
**Step 3**: Copy whatever you just built out of the build container:  
`docker cp $(docker ps -l -q):/nightly/ .`

## Details
This project is split into several branches. Each branch (besides master) contains one Dockerfile that defines a specific image that is part of the automated build system. Each of the Dockerfiles/Branches in this repository describes how a Linux file system image built and hosted [here](https://registry.hub.docker.com/repos/l3iggs/) should be generated. These images are updated automatically with updates pushes to this repository.

To use any of these images to build libretro on your own computer you must have Docker installed. Docker is available for many different environments including Windows, OSX and many different Linux flavors. Currently, Docker only works on 64 bit systems. To install docker, follow the instructions for your system [here](https://docs.docker.com/installation/)

The branches in this repository are:
- **arch-base**
 - This is the base Arch Linux image that several other build images are based upon. It does nothing when run.
- **core-builder**
 - When run, this image builds all of the cores for any Linux x86_64:  
`docker run l3iggs/libretro-core-builder`
- **retroarch-ubuntu1304-builder**
 - When run, this image builds the RetroArch front-end GUI for Ubuntu 13.04 x86_64:  
`docker run l3iggs/retroarch-ubuntu1304-builder`
- **android-builder**
 - When run, this image builds the RetroArch front-end GUI and all of the cores for Android and packages them into an .apk:  
`docker run l3iggs/libretro-android-builder`

Note that the first time you run these commands, you'll initiate a large download (the images are hosted [here](https://registry.hub.docker.com/repos/l3iggs/) before performing the build locally on your computer. This download may be on the order of 10GB (you're downloading the entire build invironment, all libretro code and all depenancies) and should only be needed once (parts of the image may have to be re-downloaded later if I need to update the build images in some way like add a dependancy or update a toolchain). Typically, the complete builds should take 10-15 minutes on most computers (after the download completes). Currently, Android builds may take longer since those builds are not using ccache at the moment. Build speed can be greatly increased by skipping the clean step. Do this by inserting `--env NOCLEAN=1` after your `docker run` command, but this might cause build errors.

Now that the binaries have been built, you must copy them out of the build environment. You can do this with the following command:  
`docker cp $(docker ps -l -q):/nightly/ .`  
That copies the build output into your current working directory. 

### Substituting upstream repos
If you wish to replace any of the upstream git repositories with your own personal repositories during the build process, do the insert a local.xml file into a folder /root/.repo/local_manifests that tells the repo tool to remove the project you want to replace and adds yours in place. For example, if you have your own personal repository for scummvm at https://github.com/l3iggs/scummvm your local.xml manifest file might look like:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remove-project name="libretro/libretro-super"/>
  <remote fetch="https://github.com/l3iggs/" name="mygithub"/>
  <project name="scummvm" path="libretro-super/libretro-scummvm" remote="mygithub" />
</manifest>
```  
To accomplish this, you'll have to "chroot" to inside the container:  
`docker run -i -t l3iggs/libretro-core-builder`
Once you've added your local.xml file to /root/.repo/local_manifests you should update the code to reflect the change you just made:
`cd /root && repo sync && repo forall -c git submodule update --init`  
then build the project
`nightly-build linux_cores`
