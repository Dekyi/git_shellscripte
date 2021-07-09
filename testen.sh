#!/bin/bash

mapfile -t dockerdir < <( dirname $(find . -maxdepth 2 | grep 'docker-compose.yml' ))

printf "%s\n" "${dockerdir[@]}"