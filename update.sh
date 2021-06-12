#!/usr/bin/env bash


# Shellscripte lernen für Systemupdates. Basis ist das Updadte.sh von Mailcow und
# die Beispiele aus dem Buch Shell-Programmierung von Wolf / Kanio
#
#

# Check permissions for root access
if [ "$(id -u)" -ne "0" ]; then
  echo "You need to be root"
  exit 1
fi

# Exit on error and pipefail
set -o pipefail

# Define variables in Bash by variable=value
# Not starting with a number. 
# 
#
#
#
#



for bin in curl docker-compose docker git awk sha1sum; do
  if [[ -z $(which ${bin}) ]]; then echo "Cannot find ${bin}, exiting..."; exit 1; fi
done



#################################################################
# Function to check online status with ping 
# Globals:
#
#
# Arguments:
#
#
#################################################################
check_online_status() {
  CHECK_ONLINE_IPS=(1.1.1.1 9.9.9.9 8.8.8.8)
  for ip in "${CHECK_ONLINE_IPS[@]}"; do
    if timeout 3 ping -c 1 ${ip} > /dev/null; then
      return 0
    fi
  done
  return 1
}

prefetch_images() {
  [[ -z ${BRANCH} ]] && { echo -e "\e[33m\nUnknown branch...\e[0m"; exit 1; }
  git fetch origin #${BRANCH}
  while read image; do
    RET_C=0
    until docker pull ${image}; do
      RET_C=$((RET_C + 1))
      echo -e "\e[33m\nError pulling $image, retrying...\e[0m"
      [ ${RET_C} -gt 3 ] && { echo -e "\e[31m\nToo many failed retries, exiting\e[0m"; exit 1; }
      sleep 1
    done
  done < <(git show origin/${BRANCH}:docker-compose.yml | grep "image:" | awk '{ gsub("image:","", $3); print $2 }')
}

echo -e "\e[32mChecking for newer update script...\e[0m"
SHA1_1=$(sha1sum update.sh)
git fetch origin #${BRANCH}
git checkout origin/${BRANCH} update.sh
SHA1_2=$(sha1sum update.sh)
if [[ ${SHA1_1} != ${SHA1_2} ]]; then
  echo "update.sh changed, please run this script again, exiting."
  chmod +x update.sh
  exit 2
fi

if [ ! $FORCE ]; then
  read -r -p "Are you sure you want to update mailcow: dockerized? All containers will be stopped. [y/N] " response
  if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo "OK, exiting."
    exit 0
  fi
fi

echo -e "\e[32mValidating docker-compose stack configuration...\e[0m"
if ! docker-compose config -q; then
  echo -e "\e[31m\nOh no, something went wrong. Please check the error message above.\e[0m"
  exit 1
fi

echo -e "\e[32mPrefetching images...\e[0m"
prefetch_images

echo -e "\e[32mStopping mailcow...\e[0m"
sleep 2
MAILCOW_CONTAINERS=($(docker-compose ps -q))
docker-compose down
echo -e "\e[32mChecking for remaining containers...\e[0m"
sleep 2
for container in "${MAILCOW_CONTAINERS[@]}"; do
  docker rm -f "$container" 2> /dev/null
done

echo -e "\e[32mFetching new images, if any...\e[0m"
sleep 2
docker-compose pull

if [[ ${SKIP_START} == "y" ]]; then
  echo -e "\e[33mNot starting mailcow, please run \"docker-compose up -d --remove-orphans\" to start mailcow.\e[0m"
else
  echo -e "\e[32mStarting mailcow...\e[0m"
  sleep 2
  docker-compose up -d --remove-orphans
fi

echo -e "\e[32mCollecting garbage...\e[0m"
docker_garbage