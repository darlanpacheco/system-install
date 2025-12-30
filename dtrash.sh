#!/usr/bin/env bash

username="$(whoami)"
userhome="/home/${username}"
cmd="${1}"
trash="${userhome}/.local/share/Trash/files"

if [ -z "${cmd}" ]; then
  exit 1
fi

if [ "${cmd}" = "status" ]; then
  eza --icons "${trash}"
elif [ "${cmd}" = "empty" ]; then
  trash-empty -f
fi
