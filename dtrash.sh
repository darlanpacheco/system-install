#!/usr/bin/env bash

cmd="${1}"
trash="${USERHOME}/.local/share/Trash/files"

if [ -z "${cmd}" ]; then
  exit 1
fi

if [ "${cmd}" = "status" ]; then
  eza --icons "${trash}"
elif [ "${cmd}" = "empty" ]; then
  trash-empty -f
fi
