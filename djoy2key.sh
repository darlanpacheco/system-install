#!/usr/bin/env bash

DEVICE="/dev/input/js0"
SELECT=8
PRESSED=0

jstest --event "${DEVICE}" | while IFS= read -r line; do
  if echo "${line}" | grep -q "type 1,.*number ${SELECT}, value 1"; then
    if [ "$PRESSED" -eq 0 ]; then
      PRESSED=1
      hyprctl dispatch closewindow class:com.libretro.RetroArch
      hyprctl dispatch closewindow class:rpcs3
      hyprctl dispatch closewindow class:shadps4
      hyprctl dispatch closewindow class:Ryujinx
    fi
  fi

  if echo "${line}" | grep -q "type 1,.*number ${SELECT}, value 0"; then
    PRESSED=0
  fi
done
