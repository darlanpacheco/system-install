#!/usr/bin/env bash

# DISPOSITIVO="/dev/input/js0"
# BOTAO_ALVO=2
#
# PRESSIONADO=0
#
# X=0
# Y=0
# HATX=0
# HATY=0
#
# jstest --event "$DISPOSITIVO" | while IFS= read -r linha; do
#   if echo "$linha" | grep -q "type 1,.*number $BOTAO_ALVO, value 1"; then
#     if [ "$PRESSIONADO" -eq 0 ]; then
#       PRESSIONADO=1
#       echo "[BUTTON]"
#     fi
#   fi
#   if echo "$linha" | grep -q "type 1,.*number $BOTAO_ALVO, value 0"; then
#     PRESSIONADO=0
#   fi
#
#   if echo "$linha" | grep -q "type 2"; then
#     num=$(echo "$linha" | sed -n 's/.*number \([0-9]\+\).*/\1/p')
#     val=$(echo "$linha" | sed -n 's/.*value \(-\?[0-9]\+\).*/\1/p')
#
#     if [ "$num" -eq 0 ]; then
#       X=$val
#     fi
#     if [ "$num" -eq 1 ]; then
#       Y=$val
#     fi
#     if [ "$num" -eq 4 ]; then
#       HATX=$val
#     fi
#     if [ "$num" -eq 5 ]; then
#       HATY=$val
#     fi
#
#     if [ "$X" -lt -10000 ]; then echo "[LEFT]"; fi
#     if [ "$X" -gt 10000 ]; then echo "[RIGHT]"; fi
#     if [ "$Y" -lt -10000 ]; then echo "[UP]"; fi
#     if [ "$Y" -gt 10000 ]; then echo "[DOWN]"; fi
#
#     if [ "$HATX" -lt 0 ]; then echo "[LEFT]"; fi
#     if [ "$HATX" -gt 0 ]; then echo "[RIGHT]"; fi
#     if [ "$HATY" -lt 0 ]; then echo "[UP]"; fi
#     if [ "$HATY" -gt 0 ]; then echo "[DOWN]"; fi
#   fi
# done

TERMSAVED=$(stty -g)

tput clear
tput civis
stty -echo -icanon

cleanup() {
  stty "$TERMSAVED"
  tput cnorm
  tput sgr0
  clear
  exit 0
}
cleanup_no_exit() {
  stty "$TERMSAVED"
  tput cnorm
  echo ""
}

trap cleanup SIGINT

WIDTH=$(tput cols)
HEIGHT=$(tput lines)
USABLE_WIDTH=$((WIDTH - 2))
TOP_LEFT="┌"
TOP_RIGHT="┐"
BOTTOM_LEFT="└"
BOTTOM_RIGHT="┘"
HORIZONTAL="─"
VERTICAL="│"

EMPTY_LINE=$(printf "%*s" $USABLE_WIDTH)

draw_horizontal_line() {
  echo -n "$1"
  for ((i = 0; i < USABLE_WIDTH; i++)); do
    echo -n "$HORIZONTAL"
  done
  echo -n "$2"
}
draw_empty_row() {
  echo "$VERTICAL$EMPTY_LINE$VERTICAL"
}

draw_text_inside() {
  local text="$1"
  local line_number="$2"
  local clean_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
  local text_length=${#clean_text}
  local right_padding=$((USABLE_WIDTH - text_length))
  [ $right_padding -lt 0 ] && right_padding=0
  local line="$VERTICAL$text$(printf "%*s" $right_padding "")$VERTICAL"
  tput cup $line_number 0
  printf "%b" "$line"
}

draw_borders() {
  draw_horizontal_line "$TOP_LEFT" "$TOP_RIGHT"
  for ((i = 0; i < HEIGHT - 2; i++)); do
    draw_empty_row
  done
  draw_horizontal_line "$BOTTOM_LEFT" "$BOTTOM_RIGHT"
}

draw_borders

RETROARCH="${HOME}/.var/app/org.libretro.RetroArch/config/retroarch"

DIRS=("neogeo" "snes" "n64" "gba" "saturn" "dreamcast" "ps1" "ps2")
EMULATORS=(
  "${RETROARCH}/cores/geolith_libretro.so"
  "${RETROARCH}/cores/mednafen_supafaust_libretro.so"
  "${RETROARCH}/cores/parallel_n64_libretro.so"
  "${RETROARCH}/cores/mgba_libretro.so"
  "${RETROARCH}/cores/mednafen_saturn_libretro.so"
  "${RETROARCH}/cores/flycast_libretro.so"
  "${RETROARCH}/cores/mednafen_psx_hw_libretro.so"
  "${RETROARCH}/cores/pcsx2_libretro.so"
)

ROMS=()
ROMS_PATH=($(find ./ -mindepth 2 -maxdepth 2))
for rom in "${ROMS_PATH[@]}"; do
  filename="${rom##*/}"
  clean_name="${filename%%.*}"
  formatted_name=$(echo "$clean_name" | tr '[:lower:]' '[:upper:]')
  ROMS+=("$formatted_name")
done
mapfile -t ROMS < <(printf "%s\n" "${ROMS[@]}" | sort)

SELECTED=0

draw_files() {
  local i
  for i in "${!ROMS[@]}"; do
    local display_name="$(basename "${ROMS[i]}")"
    if [ "$i" -eq "$SELECTED" ]; then
      draw_text_inside "\e[30;43m$display_name\e[0m" $((i + 1))
    else
      draw_text_inside "$display_name" $((i + 1))
    fi
  done
}

get_runner() {
  local file_path="$1"
  local parent_dir
  parent_dir=$(basename "$(dirname "$file_path")")

  if [[ "$parent_dir" == "neogeo" ]]; then
    echo "org.libretro.RetroArch -L ${EMULATORS[0]}"
  elif [[ "$parent_dir" == "snes" ]]; then
    echo "org.libretro.RetroArch -L ${EMULATORS[1]}"
  elif [[ "$parent_dir" == "n64" ]]; then
    echo "org.libretro.RetroArch -L ${EMULATORS[2]}"
  elif [[ "$parent_dir" == "gba" ]]; then
    echo "org.libretro.RetroArch -L ${EMULATORS[3]}"
  elif [[ "$parent_dir" == "saturn" ]]; then
    echo "org.libretro.RetroArch -L ${EMULATORS[4]}"
  elif [[ "$parent_dir" == "dreamcast" ]]; then
    echo "org.libretro.RetroArch -L ${EMULATORS[5]}"
  elif [[ "$parent_dir" == "ps1" ]]; then
    echo "org.libretro.RetroArch -L ${EMULATORS[6]}"
  elif [[ "$parent_dir" == "ps2" ]]; then
    echo "org.libretro.RetroArch -L ${EMULATORS[7]}"
  elif [[ "$parent_dir" == "ps3" ]]; then
    echo "net.rpcs3.RPCS3 --no-gui"
  fi
}

while true; do
  draw_files
  read -rsn1 key
  if [[ $key == $'\x1b' ]]; then
    read -rsn2 key
    if [[ $key == '[A' ]]; then ((SELECTED--)); fi
    if [[ $key == '[B' ]]; then ((SELECTED++)); fi
  elif [[ $key == "" ]]; then
    SELECTED_ROM="${ROMS[SELECTED]}"
    ROM=$(find ./ -maxdepth 2 -type f -iname "${SELECTED_ROM}*" | head -n 1)
    echo "${ROM}"
    RUNNER=$(get_runner "$ROM")

    cleanup_no_exit
    $RUNNER "$ROM"
  fi

  ((SELECTED < 0)) && SELECTED=0
  ((SELECTED >= ${#ROMS[@]})) && SELECTED=$((${#ROMS[@]} - 1))
done
