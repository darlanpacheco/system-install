#!/bin/bash

if [ ${1} = "dir" ]; then
  find ./ -type d | fzf --preview 'ls -la {}'
elif [ ${1} = "dirs" ]; then
  find ./ -type d | fzf --multi --bind 'space:toggle' --preview 'ls -la {}'
elif [ ${1} = "files" ]; then
  find ./ -type f | fzf --multi --bind 'space:toggle' \
    --preview '
  if file --mime-type {} | grep -q image; then
    chafa {}
  else
    cat {} 2>/dev/null | head -n 100
  fi
  '
elif [ ${1} = "copy" ]; then
  dest=$(fdir)
  while IFS= read -r ITEM; do
    cp -r ${ITEM} ${dest}
  done
elif [ ${1} = "delete" ]; then
  dest=${USERHOME}/.local/share/Trash/files/
  while IFS= read -r ITEM; do
    trash-put ${ITEM}
  done
fi
