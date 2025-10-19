#!/bin/bash

read -p "device: " DEVICE

if [[ "${DEVICE}" =~ [0-9]$ ]]; then
  PART_PREFIX="p"
else
  PART_PREFIX=""
fi

BOOT_PARTITION="${DEVICE}${PART_PREFIX}1"
SWAP_PARTITION="${DEVICE}${PART_PREFIX}2"
ROOT_PARTITION="${DEVICE}${PART_PREFIX}3"

wipefs --all --force "${DEVICE}"

echo "
label: gpt
device: ${DEVICE}
unit: MiB

size=512, type=U, bootable
size=16384, type=S
type=L
" | sfdisk "${DEVICE}"

mkfs.vfat "${BOOT_PARTITION}"
mkfs.btrfs "${ROOT_PARTITION}"
mkswap "${SWAP_PARTITION}"

mount "/dev/${ROOT_PARTITION}" /mnt
mkdir -p /mnt/boot/efi
mount "/dev/${BOOT_PARTITION}" /mnt/boot/efi
swapon "/dev/${SWAP_PARTITION}"

pacstrap -K /mnt base base-devel linux linux-lts linux-firmware

genfstab -U /mnt >>/mnt/etc/fstab

cp -r second-step.sh /mnt/root/
chmod +x /mnt/root/second-step.sh
arch-chroot /mnt /root/second-step.sh
