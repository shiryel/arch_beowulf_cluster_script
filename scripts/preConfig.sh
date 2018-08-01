#!/bin/bash

_SCRIPTPATH="$1"
mirrorsDir="$2"     # mirrorlist
pacmanCfgDir="$3"   # pacman.conf
mountPoint="$4"     # /mnt
lang="$5"           # br-abnt2

loadkeys "$lang"
timedatectl set-ntp true

if [ 'ping archlinux.org -c 1' ]; then
  echo "${green}Network OK${reset}"
  return 0
else
  echo "${red}Network FAIL${reset}"
  return 1
fi

# updateMirrorList
cat "$_SCRIPTPATH"/"$mirrorsDir" > /etc/pacman.d/mirrorlist
echo "${magenta}UPDATE MIRROR LIST COMPLETE${reset}"

pacstrap -C "$_SCRIPTPATH"/"$pacmanCfgDir" "$mountPoint" base openmpi nfs-utils grub base-devel gcc-fortran
echo "${magenta}PACKAGE COMPLETE${reset}"

genfstab -U "$mountPoint" >> "$mountPoint"/etc/fstab
echo "${magenta}FSTAB COMPLETE${reset}"
