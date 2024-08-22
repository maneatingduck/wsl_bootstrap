# Overview
These scripts are intended to help you create and setup wsl installations for use with VMs that have no connection to internet and Linux repos. 

After running the setup scripts (bs.sh and/or individual scripts) you can export the distro to a tar file, copy it to your VM, and import it into your VMs WSL instance.

# WSL version(s) and installation
We'll assume that you start with no wsl installed.
The import/exports should work with any WSL 2 installation, but I prefer the (currently) pre-release WSL versions found at https://github.com/microsoft/WSL/releases
WSL keeps its global configuration in the file .wslconfig in your windows home directory. We can set some defaults to make it play nice with windows networking, here's an example:
```
[experimental]
autoMemoryReclaim=dropcache
networkingMode=mirrored
dnsTunneling=true
firewall=true
#autoProxy=false
```

# wsl commands and files
You'll need a directory structure and some commands for manipulating distros and tar files in powershell. Here's my suggested structure:
 ```
C:\Users\aa303\wsl
                ├── tar
                ├── vhdx (hard drive files for each distro)
                │   ├── aa
                │   ├── o_ops
                │   ├── s_ops
                │   └── template
                └── wsl_bootstrap (this repo)
                    ├── logs
                    └── scripts
```
Some wsl commands:
```
# list all installed distros
wsl -l

# launch a specific distro
wsl -d aa

# remove a distro and its hard drive file (vhdx)
wsl --unregister -d template

# export a wsl distro to a tar file for copying to another machine
wsl --export -d o_ops ~/wsl/tar/o_ops.tar

# make a directory for the .vhdx file and import a distro
mkdir -p ~\wsl\vhdx\o_ops 
wsl --import -d o_ops ~\wsl\vhdx\o_ops ~\wsl\tar\o_ops.tar

```

# Preparation and defaults

To get a clean ubuntu template image we'll reinstall the default Ubuntu image. This example will use "di" as the distro name and username. The password can be "di" as well, in a wsl installation you can always get root by launching wsl -u root, so this is not an additional security risk.

powershell:
```
wsl --unregister Ubuntu
wsl --install
# username: di
# password: di
```
You'll end up in the user's home directory in the new distro. Exit with the command "exit"

## prepare a base image
Start your wsl again to enter it with wsl_bootstrap as the current directory.  

Run the following to give yourself passwordless sudo and set your user (di) as the default wsl user. When doing this you need to enter the user di's password for sudo:

```
# Make sure your user is the default wsl user, as an imported image won't have the correct registry key set. 
printf '\n[user]\ndefault=%s\n' $USER | sudo tee -a /etc/wsl.conf 

# Also add your user to sudoers with no password
printf '\n%s ALL=(ALL) NOPASSWD: ALL\n' $USER | sudo tee -a /etc/sudoers 
```

We'll use this template image as a base for subsequent distros. You can upgrade the template image with aptupgrade (and nukesnap) to save some diskspace and reduce time to create other distros:
```
# di@AA-IMC-9709427:/mnt/c/Users/aa303/wsl/wsl_bootstrap$
. bs.sh y aptupgrade nukesnap config
```
Now we'll store this image as a template, which we'll use to create other images. We'll also remove the ubuntu image to save on disk space.
Exit wsl with the command "exit", make a backup tar file:

```
# PS C:\Users\aa303\wsl\wsl_bootstrap> 
wsl --export -d ubuntu ..\tar\template.tar
wsl --unregister ubuntu
```
You now have a template.tar in the directory wsl\tar which we can use to create more images
## The bs.sh script
This script will attempt to install a selection of tools in the wsl distro. You can run it without arguments to see a list of presets and tools that can be installed:

NOTE: the prepending dot is necessary to "source" the script, so that for instance brew is in the path for the installation of kubectl
```
. bs.sh
```
Example: Install the preset omega, add dotnet, and execute automatically:
```
./bs.sh y omega dotnet
```


## Creating a deployable image for local kubernetes

I prefer to use very short distro names (such as aa for aa, o_ops for omega and so on)

```
# PS C:\Users\aa303\wsl\wsl_bootstrap> 

mkdir -Force ..\wsl\vhdx\aa
wsl --import -d aa ..\wsl\vhdx\aa ..\wsl\tar\template.tar
# launch the new distro
wsl -d aa
```
You should find yourself within the new distro in the wsl_bootstrap directory, now we're ready to install configurations and some tools with the bs.sh script. Let's install the "local_kubernetes" preset.

```
# di@AA-IMC-9709427:/mnt/c/Users/aa303/wsl/wsl_bootstrap$ 
. bs.sh y local_kubernetes
```
## Creating a deployable image for omega

We'll use the succinct name "o" for this distro
```
# PS C:\Users\aa303\wsl\wsl_bootstrap> 
mkdir -Force ..\vhdx\o
wsl --import -d o ..\vhdx\o ..\tar\template.tar
# launch the new distro
wsl -d o
```
You should find yourself within the new distro in the wsl_bootstrap directory, now we're ready to install configurations and some tools with the bs.sh script. Let's install the "omega" preset.

```
# di@AA-IMC-9709427:/mnt/c/Users/aa303/wsl/wsl_bootstrap$ 
. bs.sh y omega
```

## host links and mounts

After copying and importing the image in a vm/machine I usually create some convenient shortcuts in my wsl home directory, I'll just leave the commands here

```
winusername=aa303
# create symbolic link to windows home dir, ie. aa303
ln -sf /mnt/c/Users/$winusername ~/$winusername

# copy ssh keys from windows for ie. gitlab
mkdir -p ~/.ssh && cp $winusername/.ssh/id_rsa* ~/.ssh

# mount network drives in your home directory, for instance y:
mkdir -p ~/y && echo "y: /home/di/y drvfs defaults 0 0"|sudo tee -a /etc/fstab
sudo mount -a
```

