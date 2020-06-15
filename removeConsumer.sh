#!/bin/bash
netId=("$(docker inspect $1 | grep NetworkMode | cut -d '"' -f4)")
cgroupParent=("$(docker inspect $1 | grep CgroupParent  | cut -d '"' -f4)")
sharedLibraryPath=("$(docker inspect $1 |  grep Source | grep sharedlibrary | cut -d '"' -f4)")
docker stop $1 && docker rm $1
echo $netId
echo $cgroupParent
echo $sharedLibraryPath
