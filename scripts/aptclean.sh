#!/usr/bin/env sh
# desc: removes cache from apt
# psrereq: aptupgrade
sudo apt autoremove -y
sudo apt clean -y