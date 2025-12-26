#!/usr/bin/env bash

USERNAME=$(cat /softwares/username)
HOME=$(cat /softwares/home)
EMAIL=$(cat /softwares/email)

sudo systemctl enable --now NetworkManager

sudo pacman -S --needed mesa \
  vulkan-radeon \
  pipewire \
  pipewire-jack \
  flatpak \
  wine \
  wine-mono \
  xdg-desktop-portal \
  xdg-desktop-portal-hyprland \
  hyprland \
  hyprpicker \
  waybar \
  rofi \
  alacritty \
  gcc \
  clang \
  mingw-w64-gcc
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon --yes
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix-env -iA nixpkgs.waydroid \
  nixpkgs.linuxPackages.cpupower \
  nixpkgs.git \
  nixpkgs.git-lfs \
  nixpkgs.docker \
  nixpkgs.docker-compose \
  nixpkgs.openssh \
  nixpkgs.gammastep \
  nixpkgs.neovim \
  nixpkgs.ranger \
  nixpkgs.btop \
  nixpkgs.fastfetch \
  nixpkgs.eza \
  nixpkgs.chafa \
  nixpkgs.mpv \
  nixpkgs.nmap \
  nixpkgs.slurp \
  nixpkgs.grim \
  nixpkgs.rclone \
  nixpkgs.rsync \
  nixpkgs.trash-cli \
  nixpkgs.ffmpeg_7 \
  nixpkgs._7zz \
  nixpkgs.wl-clipboard \
  nixpkgs.bash-language-server \
  nixpkgs.shfmt \
  nixpkgs.zig \
  nixpkgs.zls \
  nixpkgs.lua-language-server \
  nixpkgs.stylua \
  nixpkgs.nodejs_20 \
  nixpkgs.vscode-langservers-extracted \
  nixpkgs.typescript-language-server \
  nixpkgs.tailwindcss-language-server \
  nixpkgs.prettier \
  nixpkgs.rojo \
  nixpkgs.adw-gtk3 \
  nixpkgs.kdePackages.breeze \
  nixpkgs.jetbrains-mono \
  nixpkgs.nerd-fonts.jetbrains-mono \
  nixpkgs.papirus-icon-theme
flatpak install flathub -y com.github.tchx84.Flatseal \
  org.mozilla.firefox \
  org.chromium.Chromium \
  org.pulseaudio.pavucontrol \
  de.haeckerfelix.Fragments \
  org.libreoffice.LibreOffice \
  org.inkscape.Inkscape \
  org.gimp.GIMP \
  com.github.libresprite.LibreSprite \
  org.blender.Blender \
  io.lmms.LMMS \
  org.audacityteam.Audacity \
  com.obsproject.Studio \
  org.vinegarhq.Vinegar \
  org.vinegarhq.Sober \
  org.libretro.RetroArch \
  net.rpcs3.RPCS3 \
  net.shadps4.shadPS4 \
  io.github.ryubing.Ryujinx \
  net.lutris.Lutris \
  com.valvesoftware.Steam \
  org.gnome.Boxes

# sudo systemctl enable --now sshd

# sudo -u ${USERNAME} ${HOME}/user.sh ${HOME}

mkdir -p "${HOME}/Desktop" "${HOME}/Documents" "${HOME}/Downloads" "${HOME}/Music" "${HOME}/Videos" "${HOME}/Projects"
mkdir -p "${HOME}/.local/npm"
mkdir -p "${HOME}/.themes" "${HOME}/.fonts" "${HOME}/.icons"

./dotfiles.sh

cp -r /usr/share/themes/* "${HOME}/.themes"
cp -r /usr/share/fonts/* "${HOME}/.fonts"
cp -r /usr/share/icons/* "${HOME}/.icons"

flatpak override --user --filesystem="${HOME}/.themes"
flatpak override --user --filesystem="${HOME}/.fonts"
flatpak override --user --filesystem="${HOME}/.icons"
flatpak override --user --filesystem=/tmp org.blender.Blender
flatpak override --user --filesystem=/home org.vinegarhq.Vinegar
flatpak override --user --env=GTK_THEME=adw-gtk3-dark
flatpak override --user --env=GTK_FONT_NAME="JetBrains Mono 12"
flatpak override --user --env=ICON_THEME=Papirus

# sudo cpupower frequency-set --max 3.8GHz not to boot once

# sudo ufw allow http
# sudo ufw allow https
# sudo ufw limit ssh
# sudo ufw default deny incoming
# sudo ufw default allow outgoing
# sudo ufw enable

# ssh-keygen -t ed25519 -C "${EMAIL}"

git lfs install

sudo rm -rf /softwares
