#!/bin/bash
containers="$(docker ps | tac | grep java-consumer| awk '{print $1}')"
lineFile="$(grep -c '' $1)"
newLine=$(($lineFile+1))
echo "$newLine"
echo "," >> $1
echo "start"


count=1
container1Created=0
while IFS= read -r container; do
    echo "Container $count"
    if [ "$(docker logs $container | grep -c 'stop check for tasks')" -lt "1000" ] 
     then
         echo "Not enough tasks done yet"
         exit 1
    fi

    count=$(expr $count + 1)
    containerStartedAt="$(docker inspect --format='{{.State.StartedAt}}' $container)"
    containerCreatedAt="$(docker inspect -f '{{ .Created }}' $container)"
    startingApplication="$(docker logs $container | head -n 20 | grep 'Starting ConsumerApplication' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])')"
    #javaStartup="$(docker logs $container | head -n 70 | grep 'Started ConsumerApplication' | cut -d ':' -f4)"
    javaConsumerStartDate="$(docker logs $container | head -n 70 | grep 'Tomcat started' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])')"
    javaReady="$(docker logs $container | head -n 80 | grep 'schedule consume for tasks' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])' | head -n 1)"
    springBootJvm="$(docker logs $container | head -n 70 | grep 'Started ConsumerApplication' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])')"
    javaDone="$(docker logs $container | head -n 80 | grep 'stop check for tasks' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])' | head -n 1)"
    java1000Tasks="$(docker logs $container  | grep  'stop check for tasks' | head -n 1000 | tail -n 1 | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])')"
    #springbootJvm="2020-07-06 13:53:51.234"

    echo ""
    echo "Exact dates"
    echo ""
    echo "Container created at: $containerCreatedAt"
    echo "Container started at: $containerStartedAt"
    echo "Application starting: $startingApplication"
    echo "Application started: $javaConsumerStartDate"
    echo "First request received: $javaReady"
    echo "Spring: $springBootJvm"
    echo "Request done: $javaDone"
    echo "1000 request done: $java1000Tasks"

    #Convert to epoch times to work with
    epochtimeStartedAt="$(date --date=$containerStartedAt +%s%3N)"
    epochtimeCreatedAt="$(date -d $containerCreatedAt +%s%3N)"
    epochtimeStartingApplication=$(date --date="$startingApplication" +%s%3N)
    epochtimeConsumerStartDate=$(date --date="$javaConsumerStartDate" +%s%3N)
    epochReady=$(date --date="$javaReady" +%s%3N)
    epochSpringboot=$(date --date="$springBootJvm" +%s%3N)
    epochDone=$(date --date="$javaDone" +%s%3N)
    epoch1000Done=$(date --date="$java1000Tasks" +%s%3N)
    
    #Check if container1 startuptime is filled
    if [ "$container1Created" -eq "0" ]; then 
      container1Created=$epochtimeCreatedAt
    fi

    echo ""
    echo "Epoch time"
    echo ""
    echo "Epoch time created at: $epochtimeCreatedAt"
    echo "Epoch time started at: $epochtimeStartedAt"
    echo "Epoch time starting application: $epochtimeStartingApplication"
    echo "Epoch time consumer start date: $epochtimeConsumerStartDate"
    echo "Epoch time task ready: $epochReady"
    echo "Epoch time spring: $epochSpringboot"
    echo "Epoch time task done: $epochDone"
    echo "Epoch time 1000 tasks done: $epoch1000Done"

    diffStartedCreated=$(($epochtimeStartedAt-$epochtimeCreatedAt))
    diffStartingStarted=$(($epochtimeStartingApplication-$epochtimeStartedAt))
    diffConsumerStartStarting=$(($epochtimeConsumerStartDate-$epochtimeStartingApplication))
    diffReadyStart=$(($epochReady-$epochtimeConsumerStartDate))
    diffSpringReady=$(($epochSpringboot-$epochtimeConsumerStartDate))
    diffDoneSpring=$(($epochDone-$epochSpringboot))
    diffTest=$(($epochDone-$epochReady))
    diffTotalTime=$(($epochDone-$epochtimeCreatedAt))
    diffTotalContainer=$(($epochDone-$container1Created))
    diffCreateContainers=$(($epochtimeCreatedAt-$container1Created))
    diffTime1000Tasks=$(($epoch1000Done-$epochReady))
    diffTime1000SinceCreation=$(($epoch1000Done-$container1Created))

    echo "test $diffTest"
    echo ""
    echo "Difference in ms"
    echo ""
    echo "Between created and started container $diffStartedCreated"
    echo "Between starting application and started container $diffStartingStarted"
    echo "Between consumer started and application starting $diffConsumerStartStarting"
    echo "Between ready and consumer start: $diffReadyStart"
    echo "Between spring and ready: $diffSpringReady"
    echo "Between done and ready: $diffDoneSpring"
    echo "Total time: $diffTotalTime"
    echo "Time since container 1 creation: $diffTotalContainer"
    echo "Difference creation since container 1: $diffCreateContainers"
    echo "1000 tasks: $diffTime1000Tasks"
    echo "Adding to csv file"

    echo "$(cat $1)$diffStartedCreated,$diffStartingStarted,$diffConsumerStartStarting,$diffSpringReady,$diffDoneSpring, $diffTime1000Tasks, $diffTotalTime,$diffCreateContainers, $diffTotalContainer,diffTime1000SinceCreation,," > $1

done <<< "$containers"
