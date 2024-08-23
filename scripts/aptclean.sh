#!/usr/bin/env sh
# desc: removes cache from apt
# psrereq: aptupgrade
sudo apt-get autoremove -y
sudo apt-get clean -y