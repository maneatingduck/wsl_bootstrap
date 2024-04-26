#!/usr/bin/bash
if [ $(id -u) -eq 0 ]; then echo "refusing to run as root, please switch to regular user";exit;fi
export WINDOWS_USER=aa303
export CURRENT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $CURRENT_DIR && . ./nukesnap.sh

time sudo apt-get update
time sudo apt-get upgrade -y
echo bootstrapping system
cd $CURRENT_DIR
cd $CURRENT_DIR && . ./home_ssh.sh
cd $CURRENT_DIR && . ./bash_case_insensitive.sh
cd $CURRENT_DIR && . ./brew.sh
cd $CURRENT_DIR && . ./k9s_kubectl_from_brew.sh
cd $CURRENT_DIR && . ./oc.sh
cd $CURRENT_DIR && . ./az.sh
cd $CURRENT_DIR && . ./teleport_tsh.sh
cd $CURRENT_DIR && . ./nukesnap.sh # and again for great justice
cd $CURRENT_DIR && . ./terraform.sh # and again for great justice
# cd $CURRENT_DIR && . ./docker.sh
# cd $CURRENT_DIR && . ./kind_ctlptl_tilt_from_brew.sh
# cd $CURRENT_DIR && . ./platform_repos.sh
# cd $CURRENT_DIR && . ./dotnet.sh
. ~/.profile
sudo apt autoremove -y
sudo apt clean -y

yes ''|brew cleanup --prune=all

# if type brew 2&>/dev/null; then brew cleanup --prune=all; fi

# printf "/lost+found\n/mnt\n/proc\n/sys\n/dev\n" |sudo du -d1 -Bm / --exclude-from -