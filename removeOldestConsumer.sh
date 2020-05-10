#!/bin/bash
container="$(docker ps | grep java-consumer | awk '{print $1}' | tail -1)"
docker stop "$container" 
docker rm "$container"
