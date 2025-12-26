#!/usr/bin/env bash

CMD="${1}"
REMOTE="${2}"
STORAGE="${3}"
RESTRICTED="${STORAGE}/restricted/"

if [ -z "${CMD}" ]; then
  exit 1
fi

if [ "${CMD}" = "status" ]; then
  sudo rclone check "${REMOTE}": "${STORAGE}" \
    --filter "- Personal Vault/**" \
    --filter "- roms/sony/**" \
    --filter "- roms/sony2/**" \
    --filter "- roms/sony3/**" \
    --filter "- roms/sony4/**" \
    --filter "- roms/nintendo5/**" \
    --progress
  sudo rclone about "${REMOTE}":
elif [ "${CMD}" = "pull" ]; then
  sudo rclone sync "${REMOTE}": "${STORAGE}" \
    --filter "- Personal Vault/**" \
    --filter "- roms/sony/**" \
    --filter "- roms/sony2/**" \
    --filter "- roms/sony3/**" \
    --filter "- roms/sony4/**" \
    --filter "- roms/nintendo5/**" \
    --progress
elif [ "${CMD}" = "push" ]; then
  sudo rclone sync "${STORAGE}" "${REMOTE}": \
    --filter "- Personal Vault/**" \
    --filter "- roms/sony/**" \
    --filter "- roms/sony2/**" \
    --filter "- roms/sony3/**" \
    --filter "- roms/sony4/**" \
    --filter "- roms/nintendo5/**" \
    --progress
elif [ "${CMD}" = "lock" ]; then
  sudo chown -R root:root "${RESTRICTED}"
  sudo chmod -R 700 "${RESTRICTED}"
elif [ "${CMD}" = "unlock" ]; then
  sudo chown -R "${USERNAME}":"${USERNAME}" "${RESTRICTED}"
  sudo chmod -R 755 "${RESTRICTED}"
fi
