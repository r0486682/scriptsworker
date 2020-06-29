#!/usr/bin/env bash

until cd app/lib/
do
    echo "retrying to accees it"
done
cd /../..
java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -cp "app:app/lib/*" "com.matthijs.consumer.ConsumerApplication"

