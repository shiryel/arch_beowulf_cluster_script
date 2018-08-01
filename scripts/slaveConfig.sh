#!/bin/bash

headnodeAddress="$1"

### NFS IMPORT
# https://wiki.archlinux.org/index.php/NFS
systemctl start nfs-client.target
mount -t nfs "$headnodeAddress":/mpi/cloud /mpi/cloud
echo "$headnodeAddress:/mpi/cloud /mpi/cloud nfs noauto,x-systemd.automount,x-systemd.device-timeout=10,timeo=14,x-systemd.idle-timeout=1min 0 0" >> /etc/fstab

### SSH CONFIG
ssh-keygen -N "" -t ecdsa -b 521 -C "node" -f /mpi/.ssh/id_ecdsa
cat /mpi/.ssh/id_ecdsa.pub >> /mpi/cloud/authorized_keys

sed -i -- 's/AuthorizedKeysFile\t.ssh\/authorized_keys/AuthorizedKeysFile\t.ssh\/authorized_keys \/mpi\/cloud\/authorized_keys/g' /etc/ssh/sshd_config

echo "UserKnownHostsFile=/mpi/cloud/known_hosts" >> /etc/ssh/ssh_config
ssh -o "StrictHostKeyChecking no" localhost

# Confirm if base-devel and fortran 77 is instaled
pacman --noconfirm -S base-devel gcc-fortran

## Configure mpich2 and hydra archives
cd /mpi/cloud/mpich
make install

cd /mpi/cloud/hydra
make install

#echo "export PATH=/mpi/cloud/mpich:/mpi/cloud/hydra:$PATH" >> /etc/profile

## Instaling primeCount
echo "export PATH=/mpi/cloud/primecount:$PATH" >> /etc/profile
