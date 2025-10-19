#!/usr/bin/env bash

TRASH=${USERHOME}/.local/share/Trash/files

if [ -z "$1" ]; then
  exit 1
fi

if [ ${1} = "status" ]; then
  eza --icons ${TRASH}
elif [ ${1} = "empty" ]; then
  trash-empty -f
fi
