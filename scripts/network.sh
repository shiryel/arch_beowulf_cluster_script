#!/bin/bash

## For public and private keys
# HostKey /etc/ssh/ssh_host_rsa_key

## Tip: É recomendavel no caso de WAN usar portas altas como 39901
## https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers

## Tip: É recomendavel tirar conecçao por senhas https://wiki.archlinux.org/index.php/Secure_Shell#Force_public_key_authentication

## Tip: sshd.socket + sshd@.service, which spawn on-demand instances of the SSH daemon per connection. Using it implies that systemd listens on the SSH socket and will only start the daemon process for an incoming connection. It is the recommended way to run sshd in almost all cases

systemctl enable dhcpcd
systemctl enable sshd.service
#pacman --noconfirm -S openssh nfs-utils cifs-utils
pacman --noconfirm -S openssh nfs-utils elixir
