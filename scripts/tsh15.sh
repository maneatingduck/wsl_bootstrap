#!/usr/bin/env sh
# desc: install teleport tsh
cd ~
mkdir -p bin
# find latest version for Linux 64-bit at https://goteleport.com/download/#install-links
export TELEPORT_FILE=teleport-v15.4.7-linux-amd64-bin.tar.gz
curl https://cdn.teleport.dev/$TELEPORT_FILE | tar --occurrence=1 -xvzf - teleport/tsh
# tar -xcvf $TELEPORT_FILE teleport/tsh
mv teleport/tsh ~/bin/tsh15
chmod 755 ~/bin/tsh15
rm -rfv teleport
