#!/bin/bash

echo "Custom entrypoint hook for Microservices Runtime"
echo "Start-time environment is:"
env | sort

# Assure SAG_HOME
SAG_HOME="${SAG_HOME:-/opt/softwareag}"

onInterrupt(){
    echo "Interrupted, shutting down MSR..."
    "${SAG_HOME}/IntegrationServer/bin/shutdown.sh"
}

trap "onInterrupt" SIGINT SIGTERM

d=$(date +%Y-%m-%dT%H.%M.%S_%3N)
mkdir -p "/mnt/local/s${d}"

echo "Capturing SAG_HOME before start"

cd "${SAG_HOME}" || exit 1

mkdir -p "/mnt/local/s${d}/01.beforeStart"

tar czf "/mnt/local/s${d}/01.beforeStart/SAG_HOME.tgz" .

echo "Starting Microservices Runtime"

cd "${SAG_HOME}/IntegrationServer/bin" || exit 2

./server.sh & 
msrPid=$!

portIsReachable(){
    (echo > /dev/tcp/${1}/${2}) >/dev/null 2>&1
    return $? 
}

# wait for MSR to come up...

while ! portIsReachable localhost 5555; do
    echo "Waiting for MSR to come up, sleeping 5..."
    sleep 5
done

cd "${SAG_HOME}" || exit 3

echo "=========== Hostname is $HOSTNAME" > "/mnt/local/s${d}/notes.txt"
echo "=========== Searching for files containing the hostname after start" >> "/mnt/local/s${d}/notes.txt"
grep -rnw . -e "$HOSTNAME" >> "/mnt/local/s${d}/notes.txt"
mkdir -p "/mnt/local/s${d}/02.afterStart"
tar czf "/mnt/local/s${d}/02.afterStart/SAG_HOME.tgz" .

wait ${msrPid}

cd "${SAG_HOME}" || exit 4
echo "=========== Searching for files containing the hostname after shutdown" >> "/mnt/local/s${d}/notes.txt"
grep -rnw . -e "$HOSTNAME" >> "/mnt/local/s${d}/notes.txt"
mkdir -p "/mnt/local/s${d}/03.afterStop" .
tar czf "/mnt/local/s${d}/03.afterStop/SAG_HOME.tgz" .

echo "MSR was shut down"