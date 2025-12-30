#!/usr/bin/env bash

read -r -p "device: " device
read -r -p "root password: " password_root
read -r -p "name: " name
read -r -p "username: " username
read -r -p "password: " password
read -r -p "email: " email

if [[ "${device}" =~ [0-9]$ ]]; then
  part_prefix="p"
else
  part_prefix=""
fi

swap_partition="${device}${part_prefix}1"
boot_partition="${device}${part_prefix}2"
root_partition="${device}${part_prefix}3"

wipefs --all --force "${device}"
cat <<EOF | sfdisk "${device}"
label: gpt
size=16GiB, type=swap
size=512MiB, type=uefi
size=+, type=linux
EOF

mkswap "${swap_partition}"
mkfs.vfat "${boot_partition}"
mkfs.btrfs "${root_partition}"

swapon "${swap_partition}"
mount "${root_partition}" /mnt
mkdir -p /mnt/boot/efi
mount "${boot_partition}" /mnt/boot/efi

pacstrap -K /mnt base base-devel linux linux-lts linux-firmware efibootmgr grub networkmanager

genfstab -U /mnt >>/mnt/etc/fstab

mkdir -p /mnt/softwares

echo "${name}" >/mnt/softwares/name
echo "${username}" >/mnt/softwares/username
echo "/home/${username}" >/mnt/softwares/userhome
echo "${email}" >/mnt/softwares/email
echo "${password}" >/mnt/softwares/password
echo "${password_root}" >/mnt/softwares/password_root

cp -r ./ddrive.sh /mnt/usr/bin/ddrive
cp -r ./dtrash.sh /mnt/usr/bin/dtrash
cp -r ./chroot.sh /mnt/softwares
cp -r ./boot.sh /mnt/softwares
cp -r ./dotfiles.sh /mnt/softwares

arch-chroot /mnt /softwares/chroot.sh
