#!/usr/bin/env bash

REMOTE=${2}
STORAGE=${3}
RESTRICTED=${STORAGE}/restricted/

if [ -z "${1}" ]; then
  exit 1
fi

if [ ${1} = "status" ]; then
  sudo rclone check ${REMOTE}: ${STORAGE} --filter "- Personal Vault/**" --progress
  sudo rclone about ${REMOTE}:
elif [ ${1} = "pull" ]; then
  sudo rclone sync ${REMOTE}: ${STORAGE} --filter "- Personal Vault/**" --progress
elif [ ${1} = "push" ]; then
  sudo rclone sync ${STORAGE} ${REMOTE}: --filter "- Personal Vault/**" --progress
elif [ ${1} = "lock" ]; then
  sudo chown -R root:root ${RESTRICTED}
  sudo chmod -R 700 ${RESTRICTED}
elif [ ${1} = "unlock" ]; then
  sudo chown -R ${USERNAME}:${USERNAME} ${RESTRICTED}
  sudo chmod -R 755 ${RESTRICTED}
fi
