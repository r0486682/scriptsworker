#!/bin/bash
listJavaConsumers="$(docker ps --all | grep java-consumer | awk '{print $1}')"
count="$(docker ps --all | grep -c java-consumer)"

if [ "$count" != 0 ]  ;
        then
          while IFS= read -r line; do
             docker stop "$line"
             docker rm "$line"
          done <<< "$listJavaConsumers"
fi
