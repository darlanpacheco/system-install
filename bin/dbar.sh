#!/usr/bin/env bash

get_cols() {
  tput cols
}
get_rows() {
  tput lines
}

get_time() {
  date +"%H:%M %a %m-%d"
}
get_volume() {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}'
}
get_cpu() {
  sensors | grep -i tctl | grep -oP '\d+(?=\.)'
}
get_gpu() {
  nvidia-smi | grep -Po '\d+(?=C )'
}
get_memv() {
  free -m | awk '/Mem:/ {printf "%.1f", $3/1024}'
}
get_memnv() {
  df -m | awk 'NR==2 {printf "%.1f", $3/1024}'
}

tput civis

while true; do
  cols=$(get_cols)
  rows=$(get_rows)
  center_row=$((rows / 2))

  time=$(get_time)
  volume=$(get_volume)
  cpu=$(get_cpu)
  gpu=$(get_gpu)
  memv=$(get_memv)
  memnv=$(get_memnv)

  space=" "
  left="${space}"
  center="${time}"
  right="VOLUME ${volume} CPU ${cpu} GPU ${gpu} MEMV ${memv} MEMNV ${memnv}${space}"

  center_pos=$(((cols / 2) - (${#center} / 2)))
  right_pos=$((cols - ${#right}))

  printf "\033[%s;1H" "${center_row}"
  printf "%s%*s%s%*s%s" \
    "${left}" \
    $((center_pos - ${#left})) "" \
    "${center}" \
    $((right_pos - center_pos - ${#center})) "" \
    "${right}"

  sleep 0.1
done
