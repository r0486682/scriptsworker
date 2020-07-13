#!/bin/bash
containers="$(docker ps | tac | grep java-consumer| awk '{print $1}')"
lineFile="$(grep -c '' $1)"
newLine=$(($lineFile+1))
echo "$newLine"
echo "," >> $1

count=1
container1Created=0
while IFS= read -r container; do
    echo "Container $count"
    count=$(expr $count + 1)
    networkContainer="$(docker inspect $container | grep NetworkMode | cut -d '"' -f4 | cut -d ':' -f2)"
    networkContainerCreated="$(docker inspect -f '{{ .Created }}' $networkContainer)"
    networkContainerStarted="$(docker inspect --format='{{.State.StartedAt}}' $networkContainer)"
    containerStartedAt="$(docker inspect --format='{{.State.StartedAt}}' $container)"
    containerCreatedAt="$(docker inspect -f '{{ .Created }}' $container)"
    startingApplication="$(docker logs $container | head -n 20 | grep 'Starting ConsumerApplication' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])')"
    #javaStartup="$(docker logs $container | head -n 70 | grep 'Started ConsumerApplication' | cut -d ':' -f4)"
    javaConsumerStartDate="$(docker logs $container | head -n 70 | grep 'Tomcat started' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])')"
    javaReady="$(docker logs $container | head -n 80 | grep 'schedule consume for tasks' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])' | head -n 1)"
    springBootJvm="$(docker logs $container | head -n 70 | grep 'Started ConsumerApplication' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])')"
    javaDone="$(docker logs $container | head -n 80 | grep 'stop check for tasks' | grep -Eo '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9])' | head -n 1)"
    #springbootJvm="2020-07-06 13:53:51.234"

    echo ""
    echo "Exact dates"
    echo ""
    echo "Networkcontainer created: $networkContainerCreated"
    echo "Networkcontaine started: $networkContainerStarted"
    echo "Container created at: $containerCreatedAt"
    echo "Container started at: $containerStartedAt"
    echo "Application starting: $startingApplication"
    echo "Application started: $javaConsumerStartDate"
    echo "First request received: $javaReady"
    echo "Spring: $springBootJvm"
    echo "Request done: $javaDone"

    #Convert to epoch times to work with
    epochNetCreate="$(date --date=$networkContainerCreated +%s%3N)"
    epochNetStarted="$(date --date=$networkContainerStarted +%s%3N)"
    epochtimeStartedAt="$(date --date=$containerStartedAt +%s%3N)"
    epochtimeCreatedAt="$(date -d $containerCreatedAt +%s%3N)"
    epochtimeStartingApplication=$(date --date="$startingApplication" +%s%3N)
    epochtimeConsumerStartDate=$(date --date="$javaConsumerStartDate" +%s%3N)
    epochReady=$(date --date="$javaReady" +%s%3N)
    epochSpringboot=$(date --date="$springBootJvm" +%s%3N)
    epochDone=$(date --date="$javaDone" +%s%3N)
    

    #Check if container1 startuptime is filled
    if [ "$container1Created" -eq "0" ]; then 
      container1Created=$epochNetCreate
    fi

    echo ""
    echo "Epoch time"
    echo ""
    echo "Epoc netcreated: $epochNetCreate"
    echo "Epoch netstarted: $epochNetStarted"
    echo "Epoch time created at: $epochtimeCreatedAt"
    echo "Epoch time started at: $epochtimeStartedAt"
    echo "Epoch time starting application: $epochtimeStartingApplication"
    echo "Epoch time consumer start date: $epochtimeConsumerStartDate"
    echo "Epoch time task ready: $epochReady"
    echo "Epoch time spring: $epochSpringboot"
    echo "Epoch time task done: $epochDone"

    diffNetCreateStarted=$(($epochNetStarted-$epochNetCreate))
    diffNetStartedCreated=$(($epochtimeCreatedAt-$epochNetStarted))
    diffStartedCreated=$(($epochtimeStartedAt-$epochtimeCreatedAt))
    diffStartingStarted=$(($epochtimeStartingApplication-$epochtimeStartedAt))
    diffConsumerStartStarting=$(($epochtimeConsumerStartDate-$epochtimeStartingApplication))
    diffReadyStart=$(($epochReady-$epochtimeConsumerStartDate))
    diffSpringReady=$(($epochSpringboot-$epochReady))
    diffDoneSpring=$(($epochDone-$epochSpringboot))
    diffTest=$(($epochDone-$epochReady))
    diffTotalTime=$(($epochDone-$epochNetCreate))
    diffTotalContainer=$(($epochDone-$container1Created))
    diffCreateContainers=$(($epochNetCreate-$container1Created))
    echo "test $diffTest"
    echo ""
    echo "Difference in ms"
    echo ""
    echo "Between net create and started: $diffNetCreateStarted"
    echo "Between net started and created: $diffNetStartedCreated"
    echo "Between created and started container $diffStartedCreated"
    echo "Between starting application and started container $diffStartingStarted"
    echo "Between consumer started and application starting $diffConsumerStartStarting"
    echo "Between ready and consumer start: $diffReadyStart"
    echo "Between spring and ready: $diffSpringReady"
    echo "Between done and ready: $diffDoneSpring"
    echo "Total time: $diffTotalTime"
    echo "Time since container 1 creation: $diffTotalContainer"
    echo "Difference pause container creation: $diffCreateContainers"

    echo "Adding to csv file"

    echo "$(cat $1)$diffNetCreateStarted,$diffNetStartedCreated,$diffStartedCreated,$diffStartingStarted,$diffConsumerStartStarting,$diffReadyStart,$diffSpringReady,$diffDoneSpring,$diffTotalTime,$diffTotalContainer,$diffCreateContainers,," > $1

done <<< "$containers"
