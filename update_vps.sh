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

#
# Define array with docerized programms. Learn how to autopopulate the array later.
#
docker_images=(seafile diun gitea wallabag freshrss tandoor dokuwiki healthchecks)
#

for bin in curl docker-compose docker git awk sha1sum; do
  if [[ -z $(which ${bin}) ]]; then echo "Cannot find ${bin}, exiting..."; exit 1; fi
done

#
# Function not used by now
#

check_online_status() {
  CHECK_ONLINE_IPS=(1.1.1.1 9.9.9.9 8.8.8.8)
  for ip in "${CHECK_ONLINE_IPS[@]}"; do
    if timeout 3 ping -c 1 "${ip}" > /dev/null; then
      return 0
    fi
  done
  return 1
}

#
# Use git to test for  
#

#echo -e "\e[32mChecking for newer update script...\e[0m"
#SHA1_1=$(sha1sum update.sh)
#git fetch origin #${BRANCH}
#git checkout origin/"${BRANCH}" update.sh
#SHA1_2=$(sha1sum update.sh)
#if [[ ${SHA1_1} != "${SHA1_2}" ]]; then
#  echo "update.sh changed, please run this script again, exiting."
#  chmod +x update.sh
#  exit 2
#fi


for image in "${docker_images[@]}"; do
  echo Updateing "$image"
  sleep 2
  cd /opt/"$image" || exit
  docker-compose pull
  docker-compose up -d
 done
