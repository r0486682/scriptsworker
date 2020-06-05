#!/bin/bash
amountOfDesiredReplicas="$1"

amountOfRunningReplicas="$(docker ps | grep -c java-consumer)"

listPrecontainers="$(docker ps | grep preconsumer | awk '{print $1}')"

listJavaConsumers="$(docker ps --all | grep java-consumer | awk '{print $1}')"

usedNetIds=()

while IFS= read -r line; do
   usedNetIds+=("$(docker inspect $line | grep NetworkMode | cut -d '"' -f4)")
done <<< "$listJavaConsumers"


isNotUsedId() {
   isUsed=0
   for id in "${usedNetIds[@]}"; do
      if [ "$1" == "$id" ]
      then
          isUsed=1
          break
      fi 
   done
   usedNetIds+=( "$1" )
}


#createName() {
#   listExistingNames= $(docker ps --all | grep java-consumer | awk '{print $13}')
#   count=1
#   while : ; do
#       if contains listExistingNames count
#       then
#           echo "java-consumer-$count"
#           break
#       fi
#       count++
#   done <<< "$listExistingNames"
#}

succeeded="no"
echo "Desired: $amountOfDesiredReplicas"
echo "Running: $amountOfRunningReplicas"
if [ "$amountOfDesiredReplicas" -gt "$amountOfRunningReplicas" ]
then
    repeat=$((amountOfDesiredReplicas-amountOfRunningReplicas))
    echo "Create $repeat containers"
    for i in $(seq 1 "$repeat")
    do
      echo "Creating container $i"
      while IFS= read -r line; do
        netId=("$(docker inspect $line | grep NetworkMode | cut -d '"' -f4)")
        isNotUsedId "$netId"
        echo "$isUsed"
        if [ "$isUsed" -eq 0 ]  ;
        then
            succeeded="yes"
            cgroup=("$(docker inspect $line | grep CgroupParent | cut -d '"' -f4)")
            library=("$(docker inspect $line | grep Source | grep sharedlibrary | cut -d '"' -f4)")
            bash createConsumer.sh "$netId" "$cgroup" "$library"
            break
        else
            succeeded="no"
        fi
      done <<< "$listPrecontainers"
    done
else
    succeed="yes"
    repeat=$((amountOfRunningReplicas-amountOfDesiredReplicas))
    echo "Removing $i containers"
    for i in $(seq 1 "$repeat")
    do
       echo "Removing container $i"
       bash removeOldestConsumer.sh
    done
fi
if [ "$succeeded" == "no" ]
then
    echo "No pods left"
fi
