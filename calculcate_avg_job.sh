#!/bin/bash
containers="$(docker ps | tac | grep java-consumer| awk '{print $1}')"

count=1

while IFS= read -r container; do
    echo "Container $count"
    #if [ "$(docker logs $container | grep -c 'stop check for tasks')" -lt "1000" ] 
    # then
    #     echo "Not enough tasks done yet"
    #     exit 1
    #fi

    javaDone="$(docker logs $container| grep 'stop check for tasks' | head -n 10 |  head -n 1 | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])')"
    java10Tasks="$(docker logs $container  | grep  'stop check for tasks' | head -n 10 | tail -n 1 | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])')"
  
    echo "Request done: $javaDone"
    echo "10 request done: $java10Tasks"

    
    epochDone=$(date --date="$javaDone" +%s%3N)
    epoch10Done=$(date --date="$java10Tasks" +%s%3N)
    

    diffTotalContainer=$(($epochDone-$epoch10Done))
    

    echo "difference $diffTotalContainer"
		

   
done <<< "$containers"

