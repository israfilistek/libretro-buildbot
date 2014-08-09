# Overview
This repo houses the Dockerfile that defines the docker image that builds libretro for linux x86_64. 

This project can be used to build linux binaries on your local machine for development/testing purposes. This image is also deployed in the cloud [here](https://registry.hub.docker.com/u/l3iggs/libretro-linux-buildimage/) for automated nightly builds of linux x86_64 binaries.

# Typical usage
1. [Install Docker](http://docs.docker.com/installation/)
1. Run the build bot:  
  `docker run l3iggs/libretro-linux-buildimage`  
   This command will fetch the build image, update libretro code and build the latest libretro and all cores
1. Extract the binary you just built:  
  `docker cp $(docker ps -l -q):/output/retroarch-linux.7z .`

# Extras
For a faster delta or incrimental build replace step 2 above with  
`docker run --env NOCLEAN=1 l3iggs/libretro-linux-buildimage`

If you wish to replace any of the upstream git repositores with your own personal repositories during the build do the following  
`TODO: docker ...`
