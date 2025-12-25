#!/usr/bin/env bash

CMD="${1}"
TRASH="${HOME}/.local/share/Trash/files"

if [ -z "${CMD}" ]; then
  exit 1
fi

if [ "${CMD}" = "status" ]; then
  eza --icons "${TRASH}"
elif [ "${CMD}" = "empty" ]; then
  trash-empty -f
fi
