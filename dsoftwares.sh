#!/usr/bin/env bash

paths=(
  "/var/lib/flatpak/exports/share/applications"
)

list_apps() {
  # Buscamos Nome e Exec, juntamos na mesma linha com um separador especial
  find "${paths[@]}" -maxdepth 2 -name "*.desktop" -exec grep -hE "^Name=|^Exec=" {} + |
    sed 'N;s/\n/\x1f/' |
    sed 's/^Name=//; s/\x1fExec=/\x1f/' |
    sed 's/ %[a-zA-Z]//g' # Limpa argumentos tipo %u ou %f
}

# O truque está aqui:
# --delimiter $'\x1f' define o separador
# --with-nth 1 diz: "Mostre apenas a primeira coluna (o Name)"
selected_line=$(list_apps | fzf \
  --delimiter=$'\x1f' \
  --with-nth=1 \
  --border=sharp \
  --layout=reverse \
  --prompt="🚀 Lançar: ")

if [ -n "${selected_line}" ]; then
  # Extraímos a segunda coluna (o Exec) da linha selecionada
  cmd=$(echo "$selected_line" | cut -d$'\x1f' -f2)

  # Roda o comando em background sem travar o terminal
  setsid bash -c "$cmd" >/dev/null 2>&1 &
fi

# apps=$( (
#   ls /usr/bin
#   flatpak list --columns=application
# ) | sort -u)
#
# choice=$(echo "${apps}" | fzf --border=sharp)
#
# if [ -n "${choice}" ]; then
#   flatpak run "${choice}" >/dev/null 2>&1 || setsid "${choice}" >/dev/null 2>&1 &
# fi
