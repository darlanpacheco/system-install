#!/bin/bash

if [ ! -f ${LOCKFILE} ]; then
  alacritty -e ${USERHOME}/alacritty.sh
fi
