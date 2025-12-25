#!/usr/bin/env bash

DEVICE=$(cat /softwares/device)
DEVICE_DRIVE=$(cat /softwares/device_drive)
USERNAME=$(cat /softwares/username)
HOME=$(cat /softwares/home)
LOCKFILE=$(cat /softwares/lockfile)
PASSWORD=$(cat /softwares/password)
PASSWORD_ROOT=$(cat /softwares/password_softwares)

useradd -m -G wheel -s /bin/bash ${USERNAME}
echo "${USERNAME}:${PASSWORD}" | chpasswd
echo "root:${PASSWORD_ROOT}" | chpasswd

tee -a /etc/sudoers >/dev/null <<EOF
${USERNAME} ALL=(ALL:ALL) ALL
EOF

cp -r /softwares/user.sh ${HOME}
cp -r /softwares/boot.sh ${HOME}
cp -r /softwares/alacritty.sh ${HOME}
cp -r /softwares/chroot.sh ${HOME}

# pacman -Syu --needed efibootmgr grub networkmanager pipewire-pulse pipewire-jack vulkan-radeon cpupower libappimage dosfstools gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly xdg-desktop-portal-hyprland xdg-desktop-portal-gtk wayland flatpak gammastep ranger mpv btop nmap slurp grim rclone rsync git git-lfs trash-cli 7zip eza chafa wl-clipboard openssh ufw fastfetch docker docker-compose hyprpicker hyprland waybar alacritty rofi neovim gcc mingw-w64-gcc clang zig zls rust shfmt npm nodejs lua-language-server stylua adw-gtk-theme breeze5 noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono ttf-jetbrains-mono-nerd papirus-icon-theme
