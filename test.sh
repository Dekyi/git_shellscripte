#!/bin/bash

mapfile -t dockerdir < <( dirname $(find . -maxdepth 2 | grep 'docker-compose.yml' ))

#printf "%s\n" "${dockerdir[@]}"

delete=(./mailcow-dockerized)

for target in "${delete[@]}"; do
  for i in "${!dockerdir[@]}"; do
    if [[ ${dockerdir[i]} = $target ]]; then
      unset 'dockerdir[i]'
    fi
  done
done

printf "%s\n" "${dockerdir[@]}"


for image in "${dockerdir[@]}"; do
  echo Update von "$image"
  sleep 1
  cd /opt/"$image" || exit
  docker compose pull
  docker compose up -d
done
