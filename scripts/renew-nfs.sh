#!/bin/bash
 
if [[ $# -ne 1 ]]; then
    echo "renew-nfs newip"
    exit 1
fi
 
newIp=$1
cp /etc/fstab /tmp/fstab
cat /tmp/fstab | grep -v "/mpi/cloud nfs noauto,x-systemd.automount,x-systemd.device-timeout=10,timeo=14,x-systemd.idle-timeout=1min 0 0" > /etc/fstab
echo "$newIp:/mpi/cloud /mpi/cloud nfs noauto,x-systemd.automount,x-systemd.device-timeout=10,timeo=14,x-systemd.idle-timeout=1min 0 0" >> /etc/fstab
