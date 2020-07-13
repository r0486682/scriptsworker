#!/bin/bash
#docker run -d  --memory=0 -v "$3:/app/lib"  --cpu-shares="368"  --cpu-period="100000" --cgroup-parent="$2" --cpu-quota="36000" --ipc="$1" --net="$1" -e "DNS_NAMESPACE=gold" -e "STRESS_SIZE=100" -e "POOL_SIZE=10" r0486682/java-consumer:testinit
docker run -d  --memory=0 -v --cpu-shares="368"  --cpu-period="100000" --cgroup-parent="$2" --cpu-quota="36000" --ipc="$1" --net="$1" -e "DNS_NAMESPACE=gold" -e "STRESS_SIZE=100" -e "POOL_SIZE=10" r0486682/java-consumer:split

