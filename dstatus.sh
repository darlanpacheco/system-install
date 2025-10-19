#!/usr/bin/env bash

get_cols() {
  tput cols
}

get_ws() {
  current=$(hyprctl activeworkspace -j | jq -r '.id')
  workspaces=$(hyprctl workspaces -j | jq -r '.[].id' | sort -n)
  out=""

  for i in ${workspaces}; do
    if [ "${i}" = "${current}" ]; then
      out="${out}[${i}] "
    else
      out="${out}${i} "
    fi
  done

  echo "${out}"
}
get_time() {
  date +"%H:%M %a %m-%d"
}
get_cpu() {
  sensors | grep -i tctl | grep -oP '\d+(?=\.)'
}
get_gpu() {
  if command -v nvidia-smi >/dev/null; then
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
  else
    sensors | grep -i edge | grep -oP '\d+(?=\.)'
  fi
}
get_ram() {
  free -m | awk '/Mem:/ {printf "%.1f", $3/1024}'
}
get_disk() {
  df -m / | awk 'NR==2 {printf "%.1fGB", $3/1024}'
}

tput civis
trap "tput cnorm; printf '\n'; exit" INT TERM
printf "\033[2J\033[H"

while true; do
  cols=$(get_cols)

  time=$(get_time)
  ws=$(get_ws)
  cpu=$(get_cpu)
  gpu=$(get_gpu)
  ram=$(get_ram)
  disk=$(get_disk)

  left=" ${ws}"
  center="${time}"
  right="CPU ${cpu}° GPU ${gpu}° RAM ${ram}GB DISK ${disk}GB "

  center_pos=$(((cols / 2) - (${#center} / 2)))
  right_pos=$((cols - ${#right}))

  printf "\r\033[2K"
  printf "%s" "${left}"
  printf "%*s%s" $((center_pos - ${#left})) "" "${center}"
  printf "%*s%s" $((right_pos - center_pos - ${#center})) "" "${right}"

  sleep 1
done
