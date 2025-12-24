#!/usr/bin/env bash

HOME=$(cat /softwares/home)

mkdir -p ${HOME}/Desktop ${HOME}/Documents ${HOME}/Downloads ${HOME}/Music ${HOME}/Videos ${HOME}/Projects
mkdir -p ${HOME}/.local/npm
mkdir -p ${HOME}/.themes ${HOME}/.fonts ${HOME}/.icons

git clone https://github.com/darlanpacheco/system-files.git ${HOME}/system-files

cp -r ${HOME}/system-files/.[!.]* ${HOME}
cp -r ${HOME}/system-files/* ${HOME}
rm -rf ${HOME}/system-files
rm -rf ${HOME}/.git

cp -r /usr/share/themes/* ${HOME}/.themes
cp -r /usr/share/fonts/* ${HOME}/.fonts
cp -r /usr/share/icons/* ${HOME}/.icons

flatpak override --user --filesystem=${HOME}/.themes
flatpak override --user --filesystem=${HOME}/.fonts
flatpak override --user --filesystem=${HOME}/.icons
flatpak override --user --env=GTK_THEME=adw-gtk3-dark
flatpak override --user --env=GTK_FONT_NAME="JetBrains Mono 12"
flatpak override --user --env=ICON_THEME=Papirus

# sudo cpupower frequency-set --max 3.8GHz not to boot once

sudo systemctl enable --now NetworkManager ufw sshd ollama

flatpak install flathub -y com.github.tchx84.Flatseal org.mozilla.firefox org.chromium.Chromium org.pulseaudio.pavucontrol de.haeckerfelix.Fragments org.libreoffice.LibreOffice org.inkscape.Inkscape org.gimp.GIMP com.github.libresprite.LibreSprite org.blender.Blender io.lmms.LMMS org.audacityteam.Audacity com.obsproject.Studio org.upscayl.Upscayl org.vinegarhq.Vinegar org.vinegarhq.Sober org.libretro.RetroArch net.rpcs3.RPCS3 net.shadps4.shadPS4 io.github.ryubing.Ryujinx net.lutris.Lutris com.valvesoftware.Steam org.gnome.Boxes

flatpak override --user --filesystem=/tmp org.blender.Blender
flatpak override --user --filesystem=/home org.vinegarhq.Vinegar

npm config set prefix ${HOME}/.local/npm
npm install -g bash-language-server typescript typescript-language-server vscode-langservers-extracted @tailwindcss/language-server prettier

sudo ufw allow http
sudo ufw allow https
sudo ufw limit ssh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

ssh-keygen -t ed25519 -C "darlanpacheco@proton.me"

git lfs install

ollama pull ministral-3:8b

touch ${LOCKFILE}

exec ${SHELL}
