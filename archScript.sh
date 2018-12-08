#!/bin/bash

###########
### MAP ###
###########
# NOTES: 
# [--] for very automany
# [-] for automany function
# [^] for semi-auto functions

# >> GLOBAL-VARS <<
#
# >> ENTRYS <<
# -- main
# - defineEntrys      // Define todas variaveis que podem ser passadas a este script
#
# >> MISCELLANEOUS <<
# setDefaultOptions // configura as definicoes locais
# verifyNetwork     // retorna 0 se a internet esta funcionando e 1 caso contrario
# findAdditionallyPacs  // Verifica se existem pacotes adicionais, se existir instala
# reboot            // reinicia o sistema
#
# >> FORMAT <<
# zapDisk           // realiza o zap all no dispositivo
# formatAndMount    // formata de acordo com os parametros
#
# >> INSTALL <<
# ^ installBase       // Instala as bases do sistema
# changeRoot        // Troca para o chroot
# - installChroot     // Instala o chroot
# bootManagerInstall  // Instala o grub
#
# >> CONFIGURE <<
# configure         // Instala pacotes adicionais, adiciona usuarios
#
# > NETWORK
# - networkConfig     // Instala e configura todo o sistema de network
# makeHostsFile       // Cria os hosts
# install_sshClient
# install_nfsClient
# install_sshServer
# install_nfsServer
#
# >> EXEC

### GLOBAL-VARS ###

export red=`tput setaf 1`
export green=`tput setaf 2`
export blue=`tput setaf 4`
export magenta=`tput setaf 5`
export reset=`tput sgr0`

### DEFAULTS

## Base vars (multiple utility)
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
scriptsDir="scripts"        # Scripts dir
mountPoint="/mnt"           # Mount Point
lang="br-abnt2"             # Configuracao de teclado para o sistema
devBase="/dev/sda"          # Device para formatacao

## format.sh vars
devSection="0"              # Particao do device que iniciara o particionamento
                            # NOTE: 0 para limpar tudo [ZAP ALL]
partitionType="GTP_BIOS"    # OPTIONS: MBR | GPT_BIOS | GPT_EFI | GPT_EFI-BIOS
memSize=`vmstat -s | head -1 | cut -f7 -d" "`+1000 # Memoria para a particao swap

## preConfig.sh vars
mirrorsDir="mirrorlist"     # Local do dispositivo com a mirrorlist
pacmanCfgDir="pacman.conf"  #pacman.conf configured for install the pac dir

## install.sh vars
inputDev="/dev/sdc1"        # Dispositivo com a mirrorlist e pacotes para instalacao

## posConfig.sh vars
password="arch-beowulf-cluster-script"
programsDir="programs"      # Pacas com os programas

## network.sh vars
# NONE

## slaveConfig.sh vars
headnodeAddress="192.168.40.70"

## headnodeConfig.sh vars
# NONE

## archScript.sh vars
noReboot=0                  # skip reboot
chroot=0                    # --chroot for arch-chroot mode
headnode=0                  # --headnode for install the headnode

preChroot() {
  bash "$SCRIPTPATH"/"$scriptsDir"/format.sh "$devBase" "$devSection" "$partitionType" "$memSize" "$mountPoint"
  echo "${magenta}format complete${reset}"]
  bash "$SCRIPTPATH"/"$scriptsDir"/preConfig.sh "$SCRIPTPATH" "$mirrorsDir" "$pacmanCfgDir" "$mountPoint" "$lang"
  echo "${magenta}pre-config complete${reset}"

  ### INSTALL BASE ###
  mkdir "$mountPoint"/chroot
  echo "${magenta}Copying for chroot... plz wait${reset}"
  cp -Rf "$SCRIPTPATH"/* "$mountPoint"/chroot
  echo "${magenta}Copy Complete"
  echo "Changing mod of chroot... ${reset}"
  chmod 777 -R "$mountPoint"/chroot
  echo "${magenta}pre-chroot complete${reset}"
  sleep 2
  if [ "$headnode" -ne 1 ]; then
    arch-chroot "$mountPoint" /usr/bin/bash /chroot/archScript.sh --chroot --device="$devBase" --partitionType="$partitionType" --language="$lang" --headnodeAddress="$headnodeAddress" --password="$password" --inputFiles="$inputDev $mirrorsDir $pacmanCfgDir $scriptsDir $programsDir"
  else
    arch-chroot "$mountPoint" /usr/bin/bash /chroot/archScript.sh --chroot --device="$devBase" --partitionType="$partitionType" --language="$lang" --headnode --password="$password" --inputFiles="$inputDev $mirrorsDir $pacmanCfgDir $scriptsDir $programsDir"
  fi
}

posChroot() {
  ### INSTALL CHROOT ###
  bash "$SCRIPTPATH"/"$scriptsDir"/install.sh "$devBase" "$partitionType"
  echo "${magenta}install complete${reset}"
  bash "$SCRIPTPATH"/"$scriptsDir"/posConfig.sh "$lang" "$password"
  echo "${magenta}pos-config complete${reset}"
  bash "$SCRIPTPATH"/"$scriptsDir"/network.sh
  echo "${magenta}network complete${reset}"

  if [ "$headnode" -ne 1 ]; then
    bash "$SCRIPTPATH"/"$scriptsDir"/slaveConfig.sh "$SCRIPTPATH" "$scriptsDir" "$headnodeAddress"
  else
    bash "$SCRIPTPATH"/"$scriptsDir"/headnodeConfig.sh "$SCRIPTPATH" "$scriptsDir" "$programsDir"
  fi

  if [ "$noReboot" -ne 1 ]; then
    exit & reboot
  fi
}

defineEntrys() {
## IN VARs:
# $@

## OUT
# chroot
# headnode
# headnodeAddress
# devBase
# devSection
# partitionType
# lang
# inputDev
# inputDir
# password


for i in "$@"; {
  case "$i" in
    --chroot)
      chroot=1
      ;;
    --headnode)
      headnode=1
      ;;
    --headnodeAddress=*)
      if [[ $i =~ --headnodeAddress=(([^\.]+\.){3}[^\.]+) ]]; then
        headnodeAddress="${BASH_REMATCH[1]}"
      else
        echo "${magenta}please insert a valid device, --headnodeAddress=[0-9,\\.]+${reset}"
        echo "headnodeAddres error" >> /chroot/errors
      fi
      ;;
    --device=*)
      if [[ $i =~ --[^=]+=(/dev/sd[a-z]) ]]; then
        devBase="${BASH_REMATCH[1]}"
      else
        echo "${magenta}please insert a valid device, --device=/dev/sd[a-z]${reset}"
        exit 1
      fi
      ;;
    --deviceSection=*)
      if [[ $i =~ --deviceSection=([1-9]+) ]]; then
        devSection="${BASH_REMATCH[1]}"
      else
        echo "${magenta}please insert a valid device, --device=[0-9]+${reset}"
        echo "${red}0 FOR ZAP ALL HARD DISK${reset}"
        exit 1
      fi
      ;;
    --partitionType=*)
      if [[ $i =~ --partitionType=(MBR_BIOS|GTP_BIOS|GTP_EFI|GPT_EFI-BIOS) ]]; then
        partitionType="${BASH_REMATCH[1]}"
      else
        echo "${magenta}please insert a valid device, --partitionType=MBR_BIOS|GTP_BIOS|GTP_EFI|GPT_EFI-BIOS${reset}"
        exit 1
      fi
      ;;
    --language=*)
      if [[ $i =~ --language=(br-abnt2) ]]; then
        lang="${BASH_REMATCH[1]}"
      else
        echo "${magenta}please insert a valid device, --language=br-abnt2${reset}"
        exit 1
      fi
      ;;
    --inputFiles=*)
      if [[ "$i" =~ --inputFiles=(/dev/sd[a-z][1-9]+)[\ ]+([^\ ]+)[\ ]+([^\ ]+)[\ ]+([^\ ]+)[\ ]+([^\ ]+) ]]; then
        inputDev="${BASH_REMATCH[1]}"
        mirrorsDir="${BASH_REMATCH[2]}"
        pacmanCfgDir="${BASH_REMATCH[3]}"
        scriptsDir="${BASH_REMATCH[4]}"
        programsDir="${BASH_REMATCH[5]}"
      else
        echo "${magenta}InputFiles ERROR... ignoring${reset}"
      fi
      ;;
    --tags=*)
      if [[ $i =~ --tags=((rapid-mode)|(no-reboot)|,)+ ]]; then
        if [[ `echo ${BASH_REMATCH[1]} | wc -c` -ne 1 ]]; then
          rapidMode=1
        fi
        if [[ `echo ${BASH_REMATCH[2]} | wc -c` -ne 1 ]]; then
          noReboot=1
        fi
      else 
        echo "${magenta}Tags dont match${reset}"
        exit 1
      fi
      ;;
    --password=*)
      if [[ $i =~ --password=(.*) ]]; then
        password="${BASH_REMATCH[1]}"
      else
        echo "${magenta}Password dont match${reset}"
        exit 1
      fi
      ;;
    -h|--help)
      echo -e "${magenta} archinstall [-h] [--\(chroot|headnode|headnodeAddress|device|deviceSection|partitionType|language|inputFiles|hostname|help\)=[COMMAND]] --tags[rapid-mode,no-reboot]+ ${reset} \n"
      echo -e "--chroot \t\t - \t ${green}Instal only the arch-chroot mode ${reset}"
      echo -e "--headnode \t\t - \t ${green}Instal the headnode ${reset}"
      echo -e "--headnodeAddress=* \t\t - \t ${green}The addres for the slaves of the headnode ${reset}"
      echo -e "--device=/dev/sd[a-z] \t\t - \t ${green}The local for partitions and instalation ${reset}"
      echo -e "--deviceSection=[0-9]+ \t\t - \t ${green}The partition num for begin the partitioning ${reset}"
      echo -e "--partitionType=\(MBR_BIOS|GTP_BIOS|GTP_EFI|GPT_EFI-BIOS\) \t - \t ${green}The partition type mode ${reset}"
      echo -e "--language=br-abnt2 \t\t - \t ${green}The language of system ${reset}"
      echo -e "--inputFiles=/dev/sd[a-z] [_MIRRORS_DIR_] [_PACS_DIR_] [_SCRIPTS_DIR_] [_PROGRAMS_DIR_] \t\t - \t ${green}The extra files for instalation ${reset}"
      echo -e "--hostname=[_HOSTNAME_] \t\t - \t ${green}Hostname of the computer ${reset}"
      echo -e "--password=\(.*\) \t\t - \t ${green}Password of computer ${reset}"
      echo -e "--tags=[rapid-mode,no-reboot]+ \t\t - \t ${green}The extra tags ${reset}"
      exit
      ;;
    *)
      echo "${red}INVALID OPTION, see -h or --help ${reset}"
      ;;
  esac
  }
}

### MAIN
defineEntrys $@

if [[ $chroot -ne 1 ]]; then
  preChroot
else
  posChroot
fi
