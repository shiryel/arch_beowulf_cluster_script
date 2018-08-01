#!/bin/bash

### FORMAT ###

devBase="$1"        # /dev/sda
devSection="$2"     # 0
partitionType="$3"  # GTP_BIOS
memSize="$4"        # system memory + 1Gb
mountPoint="$5"     # /mnt

### "archScript formatAndMount" ###

if [ "$devSection" -eq 0 ]; then
  sgdisk --zap-all "$devBase"
  partprobe "$devBase"
  ((devSection++))
  echo "$devBase ZAPED"
fi

# MORE IN: https://fitzcarraldoblog.wordpress.com/2017/02/10/partitioning-hard-disk-drives-for-bios-mbr-bios-gpt-and-uefi-gpt-in-linux/

# NOTE: Mode 1 and 3 not implemented
case "$partitionType" in
  "MBR_BIOS")
    echo "${red}Partitioning MBR with BIOS not implemented${reset}"
    ;;
  "GTP_BIOS")
    sgdisk -o "$devBase"
    sgdisk --new="$devSection":0:+2M --attributes="$devSection":set:2 --typecode="$devSection":ef02 "$devBase"
    # BIOS-GRUB -> 2MiB : attributes="legacy BIOS bootable" : code="BIOS boot partition"
    ((devSection++))

    sgdisk --new="$devSection":0:+512M	--typecode="$devSection":8300 --change-name="$devSection":BOOT "$devBase"
    # BOOT -> 512MiB : attributes=none : code="Linux filesystem" : Label="BOOT"
    partprobe "$devBase"
    mkfs.ext2 "$devBase""$devSection"
    bootPartition="$devSection"
    ((devSection++))

    sgdisk --new="$devSection":0:+"$memSize"K --typecode="$devSection":8200 --change-name="$devSection":SWAP "$devBase"
    # BOOT -> "$memSize" : attributes=none : code="Linux swap" : Label="SWAP"
    partprobe "$devBase"
    mkswap "$devBase""$devSection"
    swapon "$devBase""$devSection"
    ((devSection++))

    sgdisk --new="$devSection":0:0 --change-name="$devSection":ROOT "$devBase"
    # BOOT -> all : attributes=none : code="Linux filesystem" : Label="ROOT"
    partprobe "$devBase"
    mkfs.ext4 "$devBase""$devSection"
    mount "$devBase""$devSection" "$mountPoint"
  ;;
  "GTP_EFI")
    echo "${red}Partitioning GPT with EFI only not implemented${reset}"
  ;;
  "GPT_EFI-BIOS")
    echo "${red}Partitioning GPT with EFI/BIOS not implemented${reset}"
  ;;
esac

##### MOUNTING THE BOOT #####
mkdir "$mountPoint"/boot
mount "$devBase""$bootPartition" "$mountPoint"/boot
