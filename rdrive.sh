#!/usr/bin/env bash

STORAGE=${HOME}/storage # error
RESTRICTED=${STORAGE}/restricted/

if [ -z "$1" ]; then
  exit 1
fi

if [ ${1} = "status" ]; then
  sudo rclone check Science: ${STORAGE} --filter "- Personal Vault/**" --progress
  sudo rclone about Science:
elif [ ${1} = "pull" ]; then
  sudo rclone sync Science: ${STORAGE} --filter "- Personal Vault/**" --progress
elif [ ${1} = "push" ]; then
  sudo rclone sync ${STORAGE} Science: --filter "- Personal Vault/**" --progress
elif [ ${1} = "lock" ]; then
  sudo chown -R root:root ${RESTRICTED}
  sudo chmod -R 700 ${RESTRICTED}
elif [ ${1} = "unlock" ]; then
  sudo chown -R ${USERNAME}:${USERNAME} ${RESTRICTED}
  sudo chmod -R 755 ${RESTRICTED}
fi
