#!/bin/bash

devBase="$1"
partitionType="$2"

ln -sf /usr/share/zoneinfo/Brazil/East /etc/localtime
hwclock --systohc
locale-gen

if verifyNetwork ; then
  pacman --noconfirm -Syu
fi

mkinitcpio -p linux

case "$partitionType" in
  "MBR_BIOS")
    pacman --noconfirm -S grub
    grub-install "$devBase"
    ;;
  "GTP_BIOS")
    pacman --noconfirm -S grub
    grub-install --modules=part_gpt "$devBase"
    ;;
  "GTP_EFI")
    pacman --noconfirm -S grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub
    ;;
  "GPT_EFI-BIOS")
    echo "${red}GPT_EFI-BIOS NOT IMPLEMENTED${reset}"
    ;;
esac

grub-mkconfig -o /boot/grub/grub.cfg