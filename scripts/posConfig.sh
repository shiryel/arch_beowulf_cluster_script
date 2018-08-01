#!/bin/bash

lang="$1"
password="$2"

loadkeys "$lang"
timedatectl set-ntp true

# Root passwd
echo -e "$password\n$password" | passwd

# Mpi and Cloud directories
mkdir /mpi
mkdir /mpi/cloud

# Add user MPI
useradd --home /mpi --uid 1100 mpi
usermod -aG sudo mpi
chown -R mpi /mpi
chgrp -R mpi /mpi
