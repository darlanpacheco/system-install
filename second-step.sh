#!/bin/bash

read -p "username: " USERNAME
USERHOME="/home/${USERNAME}"
LOCKFILE=${USERHOME}/.boot_done
DIR=$(pwd)

useradd -mG wheel -s /bin/bash "${USERNAME}"
passwd "${USERNAME}"
echo "root password:"
passwd

cat <<EOF >>/etc/sudoers
${USERNAME} ALL=(ALL:ALL) ALL
EOF
cat <<EOF >>/etc/pacman.conf
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

pacman -Syu --needed efibootmgr grub networkmanager pipewire-pulse jack2 vulkan-radeon lib32-vulkan-radeon wine wine-mono libappimage unzip gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly xdg-desktop-portal-hyprland xdg-desktop-portal-gtk wayland flatpak gammastep slurp grim chafa ollama ranger wl-clipboard openssh ufw fastfetch docker docker-compose hyprpicker hyprland waybar gnome-disk-utility gnome-system-monitor alacritty nautilus rofi pavucontrol krita chromium mangohud neovim git gcc mingw-w64-gcc clang zig zls rust rust-analyzer shfmt npm nodejs lua-language-server stylua papirus-icon-theme adw-gtk-theme breeze5 ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji

grub-install
cat <<EOF >>/etc/default/grub
GRUB_GFXMODE=$(cat /sys/class/graphics/fb0/virtual_size | tr ',' 'x')
EOF
grub-mkconfig -o /boot/grub/grub.cfg

sudo -u "${USERNAME}" bash <<EOF
git clone https://github.com/darlanpacheco/system-files.git ${USERHOME}/system-files
cp -r ${USERHOME}/system-files/.[!.]* ${USERHOME}/
cp -r ${USERHOME}/system-files/* ${USERHOME}/
rm -rf ${USERHOME}/system-files/
rm -rf ${USERHOME}/.git

cp -r /usr/share/themes ${USERHOME}/.themes
cp -r /usr/share/icons ${USERHOME}/.icons
flatpak override --user --env=GTK_THEME=adw-gtk3-dark
flatpak override --user --env=ICON_THEME=Papirus
flatpak override --user --filesystem=${USERHOME}/.themes
flatpak override --user --filesystem=${USERHOME}/.icons
EOF

cat <<EOF >${USERHOME}/alacritty.sh
#!/bin/bash

mkdir -p ${USERHOME}/Desktop ${USERHOME}/Documents ${USERHOME}/Downloads ${USERHOME}/Music ${USERHOME}/Projects ${USERHOME}/Videos
mkdir -p ${USERHOME}/.local/npm

sudo systemctl enable --now NetworkManager ufw sshd
sudo systemctl start ollama

flatpak install flathub com.github.tchx84.Flatseal net.lutris.Lutris com.valvesoftware.Steam com.heroicgameslauncher.hgl org.vinegarhq.Sober org.gnome.baobab org.gnome.font-viewer org.gnome.Totem org.gnome.Loupe org.gnome.Decibels org.gnome.Boxes de.haeckerfelix.Fragments org.mozilla.firefox org.libreoffice.LibreOffice org.inkscape.Inkscape org.gimp.GIMP com.github.libresprite.LibreSprite org.blender.Blender io.lmms.LMMS com.obsproject.Studio org.localsend.localsend_app org.vinegarhq.Vinegar -y

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

exec ${SHELL}
EOF
cat <<EOF >${USERHOME}/boot.sh
#!/bin/bash

if [ ! -f "${LOCKFILE}" ]; then
  touch "${LOCKFILE}"
  alacritty -e ${USERHOME}/alacritty.sh
fi
EOF

chmod +x ${USERHOME}/alacritty.sh
chmod +x ${USERHOME}/boot.sh
