#!/bin/bash

ipa=`ip address | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
ipm=`ip address | grep -Eo 'link/ether [^\ ]*' | grep -Eo ' [^\ ]*'`

while true; do
  if [[ `ping -c 1 "google.com.br"` ]]; then
    if [[ -d /mpi/cloud ]]; then
      cp -f /mpi/cloud/nodes /mpi/cloud/nodes.tmp
      grep -vFf - /mpi/cloud/nodes.tmp < <(grep -A1 $ipm /mpi/cloud/nodes.tmp) > /mpi/cloud/nodes
      echo $ipm >> /mpi/cloud/nodes
      echo $ipa >> /mpi/cloud/nodes
      exit 0
    else
      sleep 10
    fi
  else
    sleep 5
  fi
done
