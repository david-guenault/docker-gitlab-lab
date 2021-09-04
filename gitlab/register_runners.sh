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
    echo "Register runner on gitlab"
    docker exec runner-$name bash -l -c "/usr/bin/gitlab-runner register --non-interactive --url $GITLAB_URI --registration-token $GITLAB_SHARED_RUNNER_TOKEN --executor docker --docker-image $image --name $name --docker-pull-policy always --locked=false --run-untagged=false --docker-privileged=true --limit 0 --tag-list $tags"
done < $runners_file
IFS=$OLDIFS


