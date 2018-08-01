#!/bin/bash
_SCRIPTPATH="$1"
scriptsDir="$2"   # scripts
programsDir="$3"  # programs

### NeoVim Install (4fun)
cp -Rf "$_SCRIPTPATH"/"$programsDir"/nvim ~/.config/nvim
~/.config/nvim/install.sh

### Instaling programs for work
tar -vzxf "$_SCRIPTPATH"/"$programsDir"/hydra* -C /mpi/cloud
mv /mpi/cloud/hydra* /mpi/cloud/hydra
tar -vzxf "$_SCRIPTPATH"/"$programsDir"/mpich* -C /mpi/cloud
mv /mpi/cloud/mpich* /mpi/cloud/mpich

# Confirm if base-devel and fortran 77 is instaled
pacman --noconfirm -S base-devel gcc-fortran

## Configure mpich2 and hydra archives
cd /mpi/cloud/mpich
./configure
make
make install

cd /mpi/cloud/hydra
./configure
make
make install

#echo "export PATH=/mpi/cloud/mpich:/mpi/cloud/hydra:$PATH" >> /etc/profile

## Instaling primecount
tar -Jxf "$_SCRIPTPATH"/"$programsDir"/primecount* -C /mpi/cloud
mv /mpi/cloud/primecount* /mpi/cloud/mpich
echo "export PATH=/mpi/cloud/primecount:$PATH" >> /etc/profile

### CLUSTER SSH MANAGER
# Confirm if clusterssh is instaled
pacman --noconfirm -S clusterssh

### CLUSTER-SSH CONFIG
# https://www.unixmen.com/how-to-manage-multiple-ssh-sessions-using-cluster-ssh-and-pac-manager/

### NFS EXPORT
# https://wiki.archlinux.org/index.php/NFS
systemctl enable nfs-server
echo "/mpi/cloud *(rw,sync,crossmnt,fsid=0,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -rav

### SSH CONFIG
mkdir /mpi/.ssh
ssh-keygen -N "" -t ecdsa -b 521 -C "headnode" -f /mpi/.ssh/id_ecdsa
cat /mpi/.ssh/id_ecdsa.pub >> /mpi/cloud/authorized_keys
chmod og-wx /mpi/cloud/authorized_keys

sed -i -- 's/AuthorizedKeysFile\t.ssh\/authorized_keys/AuthorizedKeysFile\t.ssh\/authorized_keys \/mpi\/cloud\/authorized_keys/g' /etc/ssh/sshd_config

echo "" >> /mpi/cloud/known_hosts
echo "UserKnownHostsFile=/mpi/cloud/known_hosts" >> /etc/ssh/ssh_config
ssh -o "StrictHostKeyChecking no" localhost


# IPs Discovery
# nmap -oX -sT -p22 <ip range>

# ssh hostname discovery
# ssh -2 -o "PreferredAuthentications=gssapi-with-mic,hostbased,publickey" \
#      <host> hostname
