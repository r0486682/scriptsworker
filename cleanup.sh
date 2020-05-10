#!/bin/bash
listJavaConsumers="$(docker ps --all | grep java-consumer | grep Exited | awk '{print $1}')"

while IFS= read -r line; do
    docker rm "$line"
done <<< "$listJavaConsumers"
