#!/bin/bash
source env.sh
runners_file="./runners.csv"

OLDIFS=$IFS
IFS=';'
basefolder="runners"
while read image name tags; do
    echo "clean runner $name"
    echo " - image: $image"
    echo " - tags: $tags"
    echo " - configuration folder $basefoler/$name"
    exist=$(docker ps -a | grep runner-$name | wc -l)
    if [ $exist -gt 0 ]; then
        echo "Remove existing runner"
        docker kill runner-$name
        docker rm -vf runner-$name
    fi
done < $runners_file
IFS=$OLDIFS


