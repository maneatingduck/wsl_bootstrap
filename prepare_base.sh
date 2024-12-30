#!/usr/bin/bash
# intended to boostrap from a bare minimum base image as root
intilityusername=intility
# ln /usr/share/zoneinfo/Europe/Oslo /etc/localtime

apt update  
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
apt install adduser sudo git bash-completion vim nano openssh-client apt-utils curl wget -y
adduser $intilityusername
printf '\n%s ALL=(ALL) NOPASSWD: ALL\n' $intilityusername | sudo tee -a /etc/sudoers
rm /etc/localtime && ln /usr/share/zoneinfo/Europe/Oslo /etc/localtime
# apt remove adduser
apt autoremove -y
apt clean -y
apt install openssh-client -y
