#!/bin/bash
source env.sh
runners_file="./runners.csv"

OLDIFS=$IFS
IFS=';'
basefolder="runners"
while read image name tags; do
    echo "Register runner $name"
    echo " - image: $image"
    echo " - tags: $tags"
    echo " - configuration folder $basefolder/$name"
    echo "Start runner runner-$name with image $image"
    docker run -d \
        --name runner-$name \
        --restart always \
        --privileged \
        -v $(pwd)/$basefolder/$name:/etc/gitlab-runner \
        -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest    
done < $runners_file
IFS=$OLDIFS


