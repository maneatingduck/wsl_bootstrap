#!/usr/bin/env sh
# desc: remove snap. This saves a lot of space
echo "Removing snap..."
# Stop the daemon
sudo systemctl disable --now snapd
# Uninstall
sudo apt-get purge -y snapd
# Tidy up dirs
sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap
# Stop it from being reinstalled by 'mistake' when installing other packages
cat << EOF | sudo tee -a /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
sudo chown root:root /etc/apt/preferences.d/no-snap.pref
# done
echo "Snap removed"
