# Overview
This repo houses the Dockerfile that defines the docker image that builds libretro cores for 64bit linux. 

This project can be used to build on your local machine for development/testing purposes. This image is also deployed in the cloud [here](https://registry.hub.docker.com/u/l3iggs/libretro-core-builder).

# Typical usage
1. [Install Docker](http://docs.docker.com/installation/)
1. Run the build bot:  
  `docker run l3iggs/libretro-core-builder`  
   This command will fetch the build image, update libretro code and run the build
1. Extract the binaries you just built:  
  `docker cp $(docker ps -l -q):/nightly/ .`

# Extras
## Delta Builds
~~For a faster delta or incremental build replace step 2 above with  
`docker run --env NOCLEAN=1 l3iggs/libretro-core-builder`~~  
 The build bot now uses ccache, so incremental builds are of little benefit.
 
## Building your own code
If you wish to replace any of the upstream git repositories with your own personal repositories during the build do the following  
`TODO: docker ... /root/.repo/local_manifest/local.xml ...`  
where `local.xml` is a xml file that describes your repositories that you'd like to use in place of the upstream ones formatted like this (for reference see the upstream default manifest .xml file [here](https://github.com/libretro/libretro-manifest/blob/master/default.xml)):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote fetch="https://github.com/l3iggs/" name="mygithub"/>
  <project name="snes9x" path="libretro-super/libretro-s9x" remote="mygithub" />
</manifest>
```
