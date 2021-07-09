#!/usr/bin/env bash
#
# 
shopt -s nullglob
 dockerdir=(dirname "$(find . -maxdepth 2 | grep ^'docker-compose.y*')")

for dir in "${dockerdir[@]}"; do
   echo "$dir"
done
