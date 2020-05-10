#!/bin/bash
listJavaConsumers="$(docker ps --all | grep java-consumer | awk '{print $1}')"

while IFS= read -r line; do
    docker stop "$line"
    docker rm "$line"
done <<< "$listJavaConsumers"
