#!/bin/bash

read -p "Enther Server ip:" ip
#read -s -p "Enther ansible password:" password
password=`sed -n '1p' ./passwd`

echo ""

ssh root@$ip "useradd ansible;echo $password | passwd --stdin ansible;usermod -aG wheel  ansible;chmod 755 /etc/sudoers;sed -i '/\%wheel\tALL=(ALL)\tALL/s/^/#/1' /etc/sudoers;sed -i '/\%wheel\tALL=(ALL)\tNOPASSWD/s/# //1' /etc/sudoers;chmod 440 /etc/sudoers"

cat ~/.ssh/id_rsa.pub | ssh ansible@$ip "umask 077; mkdir -p .ssh ; cat >> .ssh/authorized_keys"
