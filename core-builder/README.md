# Overview
This repo houses the Dockerfile that defines the docker image that builds libretro cores for linux x86_64 and Android. 

This project can be used to build cores on your local machine for development/testing purposes. This image is also deployed in the cloud [here](https://registry.hub.docker.com/u/l3iggs/libretro-core-builder) for automated nightly builds of cores.

# Typical usage
1. [Install Docker](http://docs.docker.com/installation/)
1. Run the build bot:  
  `docker run l3iggs/libretro-core-builder`  
   This command will fetch the build image, update libretro code and attempt to build all the libretro cores for Linux x86_64 and Android
1. Extract the compressed binaries you just built:  
  `docker cp $(docker ps -l -q):/nightly/ .`

# Extras
## Delta Builds
~~For a faster delta or incrimental build replace step 2 above with  
`docker run --env NOCLEAN=1 l3iggs/libretro-core-builder`~~  
 The build bot now uses ccache, so incrimental builds are of little benefit.

## Building your own code
If you wish to replace any of the upstream git repositores with your own personal repositories during the build do the following  
`TODO: docker ... /root/.repo/local_manifest/local.xml ...`  
where `local.xml` is a xml file that describes your repositories that you'd like to use in place of the upstream ones formatted like this (for reference see the upstream default manifest .xml file [here](https://github.com/libretro/libretro-manifest/blob/master/default.xml)):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote fetch="https://github.com/l3iggs/" name="mygithub"/>
  <project name="snes9x" path="libretro-super/libretro-s9x" remote="mygithub" />
</manifest>
```