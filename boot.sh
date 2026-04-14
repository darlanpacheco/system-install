#!/usr/bin/env bash

userhome="/home/$(whoami)"

sudo systemctl enable --now NetworkManager

sudo pacman -S --needed nvidia-open-lts \
	nvidia-open \
	nvidia-utils \
	pipewire \
	pipewire-pulse \
	pipewire-jack \
	flatpak \
	xdg-desktop-portal \
	xdg-desktop-portal-hyprland \
	hyprland \
	hyprpicker \
	alacritty \
	wine \
	wine-mono \
	proton-vpn-cli \
	inkscape \
	gimp \
	libresprite \
	blender \
	obs-studio \
	lmms \
	audacity \
	libreoffice-fresh \
	adw-gtk-theme \
	breeze5 \
	noto-fonts \
	noto-fonts-cjk \
	ttf-jetbrains-mono \
	ttf-jetbrains-mono-nerd
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
	nixpkgs.fastfetch \
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
	nixpkgs.zig \
	nixpkgs.zls \
	nixpkgs.bash-language-server \
	nixpkgs.shfmt \
	nixpkgs.lua-language-server \
	nixpkgs.black \
	nixpkgs.stylua \
	nixpkgs.nodejs_20 \
	nixpkgs.vscode-langservers-extracted \
	nixpkgs.typescript-language-server \
	nixpkgs.tailwindcss-language-server \
	nixpkgs.prettier
flatpak install flathub -y org.mozilla.firefox \
	org.chromium.Chromium \
	org.libretro.RetroArch \
	com.valvesoftware.Steam \
	com.heroicgameslauncher.hgl \
	org.vinegarhq.Sober \
	org.gnome.Boxes

sudo systemctl enable --now sshd

mkdir -p "${userhome}/Desktop" "${userhome}/Documents" "${userhome}/Downloads" "${userhome}/Music" "${userhome}/Videos"

flatpak override --user --env=GTK_THEME=adw-gtk3-dark
flatpak override --user --env=GTK_FONT_NAME="JetBrains Mono 12"

./dotfiles.sh
sudo rm -rf /softwares
