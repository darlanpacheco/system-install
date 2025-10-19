#!/bin/bash

STORAGE=${HOME}/storage # error
RESTRICTED=${STORAGE}/restricted/

if [ ${1} = "status" ]; then
  sudo rclone check Science: ${STORAGE} --filter "- Personal Vault/**" --filter "+ bios/pcsx2/bios/**" --filter "- bios/pcsx2/**" --filter "- bios/swanstation/**" --filter "- bios/dc/**" --progress
  sudo rclone about Science:
elif [ ${1} = "pull" ]; then
  sudo rclone sync Science: ${STORAGE} --filter "- Personal Vault/**" --progress
elif [ ${1} = "push" ]; then
  sudo rclone sync ${STORAGE} Science: --filter "- Personal Vault/**" --filter "+ bios/pcsx2/bios/**" --filter "- bios/pcsx2/**" --filter "- bios/swanstation/**" --filter "- bios/dc/**" --progress
elif [ ${1} = "lock" ]; then
  sudo chown -R root:root ${RESTRICTED}
  sudo chmod -R 700 ${RESTRICTED}
elif [ ${1} = "unlock" ]; then
  sudo chown -R ${USERHOME}:${USERHOME} ${RESTRICTED}
  sudo chmod -R 755 ${RESTRICTED}
fi
