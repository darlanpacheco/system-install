#!/usr/bin/env bash

USERNAME=$(cat /softwares/username)
HOME=$(cat /softwares/home)
PASSWORD=$(cat /softwares/password)
PASSWORD_ROOT=$(cat /softwares/password_softwares)

useradd -m -G wheel -s /bin/bash "${USERNAME}"
echo "${USERNAME}:${PASSWORD}" | chpasswd
echo "root:${PASSWORD_ROOT}" | chpasswd

tee -a /etc/sudoers >/dev/null <<EOF
${USERNAME} ALL=(ALL:ALL) ALL
EOF

grub-install --target=x86_64-efi
tee -a /etc/default/grub >/dev/null <<EOF
GRUB_GFXMODE=$(cat /sys/class/graphics/fb0/virtual_size | tr "," "x")
EOF

grub-mkconfig -o /boot/grub/grub.cfg

cp -r /softwares/alacritty.sh "${HOME}"
cp -r /softwares/chroot.sh "${HOME}"
