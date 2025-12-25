#!/usr/bin/env bash

sh <(curl --proto "=https" --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon --yes

nix-env -iA nixpkgs.efibootmgr \
  nixpkgs.grub2 \
  nixpkgs.networkmanager \
  nixpkgs.pipewire \
  nixpkgs.linuxPackages.cpupower \
  nixpkgs.flatpak \
  nixpkgs.xdg-desktop-portal \
  nixpkgs.xdg-desktop-portal-hyprland \
  nixpkgs.hyprland \
  nixpkgs.waybar \
  nixpkgs.rofi \
  nixpkgs.alacritty \
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
  nixpkgs.hyprpicker \
  nixpkgs.rclone \
  nixpkgs.rsync \
  nixpkgs.trash-cli \
  nixpkgs._7zz \
  nixpkgs.wl-clipboard \
  nixpkgs.bash-language-server \
  nixpkgs.shfmt \
  nixpkgs.zig \
  nixpkgs.zls \
  nixpkgs.libgcc \
  nixpkgs.llvmPackages_20.clang \
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
  nixpkgs.noto-fonts \
  nixpkgs.jetbrains-mono \
  nixpkgs.nerd-fonts.noto \
  nixpkgs.nerd-fonts.jetbrains-mono \
  nixpkgs.papirus-icon-theme

grub-install --target=x86_64-efi
tee -a /etc/default/grub >/dev/null <<EOF
GRUB_GFXMODE=$(cat /sys/class/graphics/fb0/virtual_size | tr "," "x")
EOF

grub-mkconfig -o /boot/grub/grub.cfg

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

sudo systemctl enable --now NetworkManager ufw sshd

flatpak install flathub -y com.github.tchx84.Flatseal org.mozilla.firefox org.chromium.Chromium org.pulseaudio.pavucontrol de.haeckerfelix.Fragments org.libreoffice.LibreOffice org.inkscape.Inkscape org.gimp.GIMP com.github.libresprite.LibreSprite org.blender.Blender io.lmms.LMMS org.audacityteam.Audacity com.obsproject.Studio org.upscayl.Upscayl org.vinegarhq.Vinegar org.vinegarhq.Sober org.libretro.RetroArch net.rpcs3.RPCS3 net.shadps4.shadPS4 io.github.ryubing.Ryujinx net.lutris.Lutris com.valvesoftware.Steam org.gnome.Boxes

flatpak override --user --filesystem=/tmp org.blender.Blender
flatpak override --user --filesystem=/home org.vinegarhq.Vinegar

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

rm -rf /softwares
