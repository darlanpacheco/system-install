#!/bin/bash

read -p "username: " USERNAME
USERHOME="/home/${USERNAME}"
LOCKFILE=${USERHOME}/.boot_done
DIR=$(pwd)

useradd -mG wheel -s /bin/bash "${USERNAME}"
passwd "${USERNAME}"
echo "root password:"
passwd

tee -a /etc/sudoers >/dev/null <<EOF
${USERNAME} ALL=(ALL:ALL) ALL
EOF
tee -a /etc/pacman.conf >/dev/null <<EOF
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

pacman -Syu --needed efibootmgr grub networkmanager pipewire-pulse jack2 vulkan-radeon lib32-vulkan-radeon wine wine-mono libappimage trash-cli unzip gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly xdg-desktop-portal-hyprland xdg-desktop-portal-gtk wayland flatpak gammastep slurp grim fzf chafa ollama wl-clipboard openssh ufw fastfetch docker docker-compose hyprpicker hyprland waybar gnome-disk-utility gnome-system-monitor alacritty rofi pavucontrol krita chromium neovim git gcc mingw-w64-gcc clang zig zls rust rust-analyzer shfmt npm nodejs lua-language-server stylua papirus-icon-theme adw-gtk-theme breeze5 ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji

grub-install
tee -a /etc/default/grub >/dev/null <<EOF
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

tee ${USERHOME}/alacritty.sh >/dev/null <<EOF
#!/bin/bash

mkdir -p ${USERHOME}/Desktop ${USERHOME}/Documents ${USERHOME}/Downloads ${USERHOME}/Music ${USERHOME}/Projects ${USERHOME}/Videos
mkdir -p ${USERHOME}/.local/npm

sudo systemctl enable --now NetworkManager ufw sshd
sudo systemctl start ollama

flatpak install flathub com.github.tchx84.Flatseal net.lutris.Lutris com.valvesoftware.Steam com.heroicgameslauncher.hgl org.vinegarhq.Sober org.gnome.baobab org.gnome.font-viewer org.gnome.Totem org.gnome.Loupe org.gnome.Decibels org.gnome.Boxes de.haeckerfelix.Fragments org.mozilla.firefox org.libreoffice.LibreOffice org.inkscape.Inkscape org.gimp.GIMP com.github.libresprite.LibreSprite org.blender.Blender io.lmms.LMMS com.obsproject.Studio org.upscayl.Upscayl org.localsend.localsend_app org.vinegarhq.Vinegar -y

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
tee ${USERHOME}/boot.sh >/dev/null <<EOF
#!/bin/bash

if [ ! -f "${LOCKFILE}" ]; then
  touch "${LOCKFILE}"
  alacritty -e ${USERHOME}/alacritty.sh
fi
EOF

chmod +x ${USERHOME}/alacritty.sh
chmod +x ${USERHOME}/boot.sh

tee /usr/bin/fdir >/dev/null <<'EOF'
#!/bin/bash
find ./ -type d | fzf --preview 'ls -la {}'
EOF
tee /usr/bin/fdirs >/dev/null <<'EOF'
#!/bin/bash
find ./ -type d | fzf --multi --bind 'space:toggle' --preview 'ls -la {}'
EOF
tee /usr/bin/ffiles >/dev/null <<'EOF'
#!/bin/bash
find ./ -type f | fzf --multi --bind 'space:toggle' \
  --preview '
    if file --mime-type {} | grep -q image; then
        chafa {}
    else
        cat {} 2>/dev/null | head -n 100
    fi
  '
EOF
tee /usr/bin/fcopy >/dev/null <<'EOF'
#!/bin/bash
dest=$(fdir)
while IFS= read -r ITEM; do
  cp -r "$ITEM" "$dest"
done
EOF
tee /usr/bin/fdelete >/dev/null <<'EOF'
#!/bin/bash
dest=~/.local/share/Trash/files/
while IFS= read -r ITEM; do
  trash-put "$ITEM"
done
EOF

chmod +x /usr/bin/fdir
chmod +x /usr/bin/fdirs
chmod +x /usr/bin/ffiles
chmod +x /usr/bin/fcopy
chmod +x /usr/bin/fdelete
