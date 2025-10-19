#!/usr/bin/env bash

userhome="/home/$(whoami)"
email=$(cat /softwares/email)

sudo systemctl enable --now NetworkManager

sudo pacman -S --needed nvidia-open-lts \
  nvidia-open \
  nvidia-utils \
  pipewire \
  pipewire-jack \
  flatpak \
  xdg-desktop-portal \
  xdg-desktop-portal-hyprland \
  hyprland \
  hyprpicker \
  waybar \
  rofi \
  alacritty \
  wine \
  wine-mono \
  ufw \
  openssh \
  proton-vpn-cli
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon --yes
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix-env -iA nixpkgs.lm_sensors \
  nixpkgs.pulsemixer \
  nixpkgs.btrfs-progs \
  nixpkgs.dosfstools \
  nixpkgs.git \
  nixpkgs.docker \
  nixpkgs.docker-compose \
  nixpkgs.openssh \
  nixpkgs.gammastep \
  nixpkgs.neovim \
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
  org.inkscape.Inkscape \
  org.gimp.GIMP \
  com.github.libresprite.LibreSprite \
  org.blender.Blender \
  io.lmms.LMMS \
  org.audacityteam.Audacity \
  com.obsproject.Studio \
  org.libreoffice.LibreOffice \
  org.gnome.Boxes \
  org.libretro.RetroArch \
  net.lutris.Lutris \
  com.valvesoftware.Steam \
  org.vinegarhq.Vinegar \
  org.vinegarhq.Sober

sudo systemctl enable --now ufw sshd

mkdir -p "${userhome}/Desktop" "${userhome}/Documents" "${userhome}/Downloads" "${userhome}/Music" "${userhome}/Videos" "${userhome}/Projects"

# mkdir -p "${userhome}/.themes" "${userhome}/.fonts" "${userhome}/.icons"
# ln -sfn "${userhome}/.nix-profile/share/icons" "${userhome}/.icons"
# ln -sfn "${userhome}/.nix-profile/share/themes" "${userhome}/.themes"
# ln -sfn "${userhome}/.nix-profile/share/fonts" "${userhome}/.fonts"
# ln -sfn "${userhome}/.nix-profile/share/icons" "${userhome}/.local/share/icons"
# ln -sfn "${userhome}/.nix-profile/share/themes" "${userhome}/.local/share/themes"
# ln -sfn "${userhome}/.nix-profile/share/fonts" "${userhome}/.local/share/fonts"
# flatpak override --user --filesystem="${userhome}/.themes"
# flatpak override --user --filesystem="${userhome}/.fonts"
# flatpak override --user --filesystem="${userhome}/.icons"
# flatpak override --user --filesystem=/tmp org.blender.Blender
# flatpak override --user --filesystem=/home org.vinegarhq.Vinegar
# flatpak override --user --env=GTK_THEME=adw-gtk3-dark
# flatpak override --user --env=GTK_FONT_NAME="JetBrains Mono 12"
# flatpak override --user --env=ICON_THEME=Papirus

sudo ufw allow http
sudo ufw allow https
sudo ufw limit ssh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

ssh-keygen -t ed25519 -C "${email}"

./dotfiles.sh
sudo rm -rf /softwares
