#!/usr/bin/env bash

if [ ! -f ${LOCKFILE} ]; then
  alacritty -e ${HOME}/alacritty.sh
fi
