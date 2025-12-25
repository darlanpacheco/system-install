#!/usr/bin/env bash

read -r -p "device: " DEVICE
read -r -p "username: " USERNAME
read -r -p "password: " PASSWORD
read -r -p "root password: " PASSWORD_ROOT
read -r -p "email: " EMAIL

if [[ "${DEVICE}" =~ [0-9]$ ]]; then
  PART_PREFIX="p"
else
  PART_PREFIX=""
fi

SWAP_PARTITION="${DEVICE}${PART_PREFIX}1"
BOOT_PARTITION="${DEVICE}${PART_PREFIX}2"
ROOT_PARTITION="${DEVICE}${PART_PREFIX}3"

wipefs --all --force "${DEVICE}"
cat <<EOF | sfdisk "${DEVICE}"
label: gpt
size=16GiB, type=swap
size=512MiB, type=uefi
size=+, type=linux
EOF

mkswap "${SWAP_PARTITION}"
mkfs.vfat "${BOOT_PARTITION}"
mkfs.btrfs "${ROOT_PARTITION}"

swapon "${SWAP_PARTITION}"
mount "${ROOT_PARTITION}" /mnt
mkdir -p /mnt/boot/efi
mount "${BOOT_PARTITION}" /mnt/boot/efi

pacstrap -K /mnt base base-devel linux linux-lts linux-firmware efibootmgr grub networkmanager

genfstab -U /mnt >>/mnt/etc/fstab

mkdir -p /mnt/softwares

echo "${DEVICE}" >/mnt/softwares/device
echo "${USERNAME}" >/mnt/softwares/username
echo "/home/${USERNAME}" >/mnt/softwares/home
echo "${EMAIL}" >/mnt/softwares/email
echo "${HOME}/.lock" >/mnt/softwares/lockfile
echo "${PASSWORD}" >/mnt/softwares/password
echo "${PASSWORD_ROOT}" >/mnt/softwares/password_root

cp -r ./rdrive.sh /mnt/usr/bin/rdrive
cp -r ./boot.sh /mnt/softwares
cp -r ./alacritty.sh /mnt/softwares
cp -r ./chroot.sh /mnt/softwares

arch-chroot /mnt /softwares/chroot.sh
