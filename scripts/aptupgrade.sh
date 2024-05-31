#!/usr/bin/env sh
# desc: updates apt and upgrades all packages
# postreq: aptclean

sudo apt-get update
sudo apt-get upgrade -y
