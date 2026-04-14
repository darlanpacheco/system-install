#!/usr/bin/env bash

cmd="${1}"
remote="${2}"
storage="${3}"
restricted="${storage}/restricted/"
username="$(whoami)"
filters=(
  "--filter=+ library/musics/**"
  "--filter=- library/**"
  "--filter=- Personal Vault/**"
  "--filter=- .Trash*/**"
)

if [ -z "${cmd}" ]; then
  exit 1
fi

if [ "${cmd}" = "status" ]; then
  sudo rclone check "${remote}": "${storage}" \
    "${filters[@]}" \
    --progress
  sudo rclone about "${remote}":
elif [ "${cmd}" = "pull" ]; then
  sudo rclone sync "${remote}": "${storage}" \
    "${filters[@]}" \
    --progress
elif [ "${cmd}" = "push" ]; then
  sudo rclone sync "${storage}" "${remote}": \
    "${filters[@]}" \
    --progress
elif [ "${cmd}" = "lock" ]; then
  sudo chown -R root:root "${restricted}"
  sudo chmod -R 700 "${restricted}"
elif [ "${cmd}" = "unlock" ]; then
  sudo chown -R "${username}":"${username}" "${restricted}"
  sudo chmod -R 755 "${restricted}"
fi
