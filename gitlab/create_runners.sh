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
    mkdir -p $basefolder/$name/certs
    sudo cp ${GITLAB_SSL_CA} $basefolder/$name/certs/ca.crt
    docker run -d \
        --name runner-$name \
        --restart always \
        --privileged \
        -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/$basefolder/$name:/etc/gitlab-runner \
        gitlab/gitlab-runner:latest
done < $runners_file
IFS=$OLDIFS


