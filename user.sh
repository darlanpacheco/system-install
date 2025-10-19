#!/usr/bin/env bash

USERHOME=$(cat /softwares/userhome)

mkdir -p ${USERHOME}/Desktop ${USERHOME}/Documents ${USERHOME}/Downloads ${USERHOME}/Music ${USERHOME}/Videos ${USERHOME}/Projects
mkdir -p ${USERHOME}/.local/npm
mkdir -p ${USERHOME}/.themes ${USERHOME}/.fonts ${USERHOME}/.icons

git clone https://github.com/darlanpacheco/system-files.git ${USERHOME}/system-files

cp -r ${USERHOME}/system-files/.[!.]* ${USERHOME}
cp -r ${USERHOME}/system-files/* ${USERHOME}
rm -rf ${USERHOME}/system-files
rm -rf ${USERHOME}/.git

cp -r /usr/share/themes/* ${USERHOME}/.themes
cp -r /usr/share/fonts/* ${USERHOME}/.fonts
cp -r /usr/share/icons/* ${USERHOME}/.icons

flatpak override --user --filesystem=${USERHOME}/.themes
flatpak override --user --filesystem=${USERHOME}/.fonts
flatpak override --user --filesystem=${USERHOME}/.icons
flatpak override --user --env=GTK_THEME=adw-gtk3-dark
flatpak override --user --env=GTK_FONT_NAME="JetBrains Mono 12"
flatpak override --user --env=ICON_THEME=Papirus
