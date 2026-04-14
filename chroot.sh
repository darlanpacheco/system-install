#!/usr/bin/env bash

username=$(cat /softwares/username)
userhome="/home/${username}"
password=$(cat /softwares/password)
password_root=$(cat /softwares/password_root)

useradd -m -s /bin/bash -G wheel "${username}"
echo "${username}:${password}" | chpasswd
echo "root:${password_root}" | chpasswd

tee -a /etc/sudoers >/dev/null <<EOF
%wheel ALL=(ALL:ALL) ALL
EOF

grub-install --target=x86_64-efi
tee -a /etc/default/grub >/dev/null <<EOF
GRUB_GFXMODE=$(cat /sys/class/graphics/fb0/virtual_size | tr "," "x")
EOF

grub-mkconfig -o /boot/grub/grub.cfg

cp -r /softwares/dotfiles.sh "${userhome}"
cp -r /softwares/boot.sh "${userhome}"
