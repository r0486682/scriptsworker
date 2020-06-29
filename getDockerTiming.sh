#!/bin/bash
containers="$(docker ps | tac | grep java-consumer| awk '{print $1}')"
count=1
while IFS= read -r container; do
    echo "Container $count"
    count=$(expr $count + 1)
    containerStartedAt="$(docker inspect --format='{{.State.StartedAt}}' $container)"
    epochtime="$(date --date=$containerStartedAt +%s%3N)"
    javaStartup="$(docker logs $container | head -n 70 | grep 'Started ConsumerApplication' | cut -d ':' -f4)"
    dif=$(($epochtime-$1))
    echo "Time difference (milliseconds):  $dif"
    echo $javaStartup
done <<< "$containers"
