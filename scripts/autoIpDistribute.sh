#!/bin/bash

alias ip="ip address | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias ipm="ip address | grep -Eo 'link/ether [^\ ]*' | grep -Eo ' [^\ ]*'"

while true; do
  if [ ping "google.com.br" ]; then
    ipm >> /mpi/cloud/nodes
    ip >> /mpi/cloud/nodes
    exit 0
  else
    sleep 10
  fi
done
