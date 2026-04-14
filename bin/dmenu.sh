#!/usr/bin/env bash

userhome="/home/$(whoami)"
cache_file="${userhome}/.cache/app_launcher_cache"
cache_max_age=256

app_dirs=(
  /usr/share/applications
  /usr/local/share/applications
  "${userhome}/.local/share/applications"
)

update_cache() {
  mkdir -p "$(dirname "${cache_file}")"

  find "${app_dirs[@]}" \
    -name "*.desktop" -print0 2>/dev/null |
    while IFS= read -r -d '' file; do
      grep -q "^NoDisplay=true" "${file}" && continue

      name=$(grep -m1 "^Name=" "${file}" | cut -d= -f2-)
      exec=$(grep -m1 "^Exec=" "${file}" | cut -d= -f2-)
      exec=$(echo "${exec}" | sed 's/ %[a-zA-Z]//g')

      [ -n "${name}" ] && [ -n "${exec}" ] && echo "${name} | ${exec}"
    done | sort -u >"${cache_file}"
}

if [ ! -f "${cache_file}" ]; then
  update_cache
else
  now=$(date +%s)
  modified=$(stat -c %Y "${cache_file}")
  age=$((now - modified))

  if [ "${age}" -gt "${cache_max_age}" ]; then
    update_cache
  fi
fi

selection=$(cat "${cache_file}" | fzf --layout=reverse --gutter=' ' --pointer=' ')

if [ -n "${selection}" ]; then
  command=$(echo "${selection}" | cut -d'|' -f2 | sed 's/^ *//')
  setsid "${command}" >/dev/null 2>&1 &
fi
