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

pacman -Syu --needed efibootmgr grub networkmanager pipewire-pulse pipewire-jack vulkan-radeon cpupower libappimage dosfstools gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly xdg-desktop-portal-hyprland xdg-desktop-portal-gtk wayland flatpak gammastep ranger mpv btop nmap slurp grim rclone rsync git git-lfs trash-cli 7zip eza chafa ollama wl-clipboard openssh ufw fastfetch docker docker-compose hyprpicker hyprland waybar alacritty rofi neovim gcc mingw-w64-gcc clang zig zls rust shfmt npm nodejs lua-language-server stylua adw-gtk-theme breeze5 noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono ttf-jetbrains-mono-nerd papirus-icon-theme

grub-install --target=x86_64-efi
tee -a /etc/default/grub >/dev/null <<EOF
GRUB_GFXMODE=$(cat /sys/class/graphics/fb0/virtual_size | tr "," "x")
EOF

grub-mkconfig -o /boot/grub/grub.cfg

cp -r /softwares/user.sh ${HOME}
cp -r /softwares/boot.sh ${HOME}
cp -r /softwares/alacritty.sh ${HOME}
cp -r /softwares/chroot.sh ${HOME}

# sudo -u ${USERNAME} ${HOME}/user.sh ${HOME}

tee ${HOME}/.bashrc >/dev/null <<EOF
alias c="clear"
alias e="exit"

alias rm="trash"
alias ls="eza --icons"

alias install="sudo pacman -S --needed"
alias uninstall="sudo pacman -Rns"
alias update="sudo pacman -Syu && flatpak update -y && npm update -g"
alias search="pacman -Ss"
alias list="pacman -Q"

alias gts="git status"
alias gta="git add"
alias gtc="git commit"
alias gtp="git push"
alias gtl="git log"

terminal() {
  alacritty --working-directory \${PWD} &
}

export EDITOR=nvim
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_BACKEND=wayland
export GDK_BACKEND=wayland
export GTK_THEME=adw-gtk3-dark
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=gtk3
export PATH=\${PATH}:\${HOME}/.local/npm/bin
export PATH=\${PATH}:\${HOME}/.cargo/bin
export DEVICE=${DEVICE}
export DEVICE_DRIVE=${DEVICE_DRIVE}
export USERNAME=${USERNAME}
export HOME=${HOME}
export LOCKFILE=${LOCKFILE}
EOF

rm -rf /softwares
