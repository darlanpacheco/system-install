#!/bin/bash

sudo systemctl enable --now NetworkManager ufw sshd
sudo systemctl start ollama

flatpak install flathub com.github.tchx84.Flatseal org.libretro.RetroArch net.lutris.Lutris com.valvesoftware.Steam com.heroicgameslauncher.hgl org.vinegarhq.Sober org.gnome.baobab org.gnome.Totem org.gnome.Loupe org.gnome.Decibels org.gnome.Boxes de.haeckerfelix.Fragments org.mozilla.firefox org.libreoffice.LibreOffice org.inkscape.Inkscape org.gimp.GIMP com.github.libresprite.LibreSprite org.blender.Blender io.lmms.LMMS org.audacityteam.Audacity com.obsproject.Studio org.upscayl.Upscayl org.localsend.localsend_app org.vinegarhq.Vinegar -y

flatpak override --user --filesystem=/tmp org.blender.Blender
flatpak override --user --filesystem=/home org.vinegarhq.Vinegar

npm config set prefix ${USERHOME}/.local/npm
npm install -g bash-language-server typescript typescript-language-server vscode-langservers-extracted @tailwindcss/language-server prettier

ollama pull llama3.2
ollama pull codellama

sudo ufw allow http
sudo ufw allow https
sudo ufw limit ssh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

ssh-keygen -t ed25519 -C "darlanpacheco@proton.me"

git lfs install

touch ${LOCKFILE}

exec ${SHELL}
