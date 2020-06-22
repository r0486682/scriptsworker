#!/bin/bash
listPrecontainers="$(docker ps | grep r0486682/pause | awk '{print $1}')"


while IFS= read -r line; do
        netId=("$(docker inspect $line | grep NetworkMode | cut -d '"' -f4)")
        cgroupParent=("$(docker inspect $line | grep CgroupParent  | cut -d '"' -f4)")
        sharedLibraryPath=("$(docker inspect $line |  grep Source | grep sharedlibrary | cut -d '"' -f4)")

        echo $netId 
        echo $cgroupParent 
        echo $sharedLibraryPath
done <<< "$listPrecontainers"

