#!/usr/bin/env bash

sudo cpupower frequency-set --max 3.8GHz

sudo systemctl enable --now NetworkManager ufw sshd ollama

flatpak install flathub -y com.github.tchx84.Flatseal org.mozilla.firefox org.chromium.Chromium org.pulseaudio.pavucontrol de.haeckerfelix.Fragments org.libreoffice.LibreOffice org.inkscape.Inkscape org.gimp.GIMP com.github.libresprite.LibreSprite org.blender.Blender io.lmms.LMMS org.audacityteam.Audacity com.obsproject.Studio org.upscayl.Upscayl org.vinegarhq.Vinegar org.vinegarhq.Sober org.libretro.RetroArch net.rpcs3.RPCS3 net.shadps4.shadPS4 io.github.ryubing.Ryujinx net.lutris.Lutris com.valvesoftware.Steam org.gnome.Boxes

flatpak override --user --filesystem=/tmp org.blender.Blender
flatpak override --user --filesystem=/home org.vinegarhq.Vinegar

npm config set prefix ${USERHOME}/.local/npm
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
