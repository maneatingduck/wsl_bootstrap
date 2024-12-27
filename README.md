# Overview
These scripts are intended to help you create and setup wsl installations for use with VMs that have no connection to internet and Linux repos. 

After running the setup scripts (bs.sh and/or individual scripts) you can export the distro to a tar file, copy it to your VM, and import it into your VMs WSL instance.
# TLDR
If you're running this on a Hyper-V VM, we need to turn on nested virtualization.  
In host powershell terminal, with all vms turned off:
```
get-vm |Set-VMProcessor -ExposeVirtualizationExtensions $true
```
Inside the VM or bare-metal Win11 PC we need to enable Hyper-V. In Powershell as Admin:
```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```
Reboot, it's the only way to be sure.  
Install a preview or stable version of wsl2 from https://github.com/microsoft/WSL/releases  
Launch a Powershell terminal to do some setup:
```
# write windows wsl-config
write-host "[experimental]`nautoMemoryReclaim=dropcache`nnetworkingMode=mirrored`ndnsTunneling=true`nfirewall=true`n#autoProxy=false`na">$HOME\.wslconfig
# create directory structure:
cd $HOME;mkdir -Force $HOME\wsl\tar;mkdir -Force $HOME\wsl\vhdx;mkdir -force $HOME\wsl\wsl_bootstrap;cd $HOME\wsl
```

Now you'll need a .tar file with a distro inside it. Create one yourself by exporting from an existing wsl install somewhere else or get a ready made one from DevInfra. Put it in the wsl\tar directory inside your home directory. 

```
wsl --import example $HOME\wsl\vhdx\example $HOME\wsl\tar\example.tar

# run it
wsl -d example
```
Inside the DevInfra-provided distros there are a couple of scripts you can run to mount windows network drives inside the distro, and also copy .gitconfig and .ssh keys from windows:
```
# in bash
~/winconfig.sh && ~/mount_network_drives.sh
```

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
# VM Nested virtualization and Hyper-V

## nested virtualization

If you're installing in a virtual machine, you need to enable nested virtualization with the machine turned off, since wsl uses the Hyper-V feature.  
Run the following powershell command on the host. The example assumes that the vm is called sigma-something:
```
#set for single vm whose name starts with "Sigma"
get-vm -Name "Sigma*"|Set-VMProcessor -ExposeVirtualizationExtensions $true

#set for all VMs
get-vm |Set-VMProcessor -ExposeVirtualizationExtensions $true
```
## Enable Hyper-V inside the vm
We need this in order to be able to run wsl. Wsl --install will enable this for you, but that only works if you're online.

Log in to the VM
GUI: In start menu, search for Turn Windows features on or off, enable all Hyper-V features  

Powershell as Admin:
```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```
# wsl commands and files
You'll need a directory structure and some commands for manipulating distros and tar files in powershell. Here's my suggested structure, which this guide will assume:
 ```
C:\Users\aa303\wsl
                ├── tar
                ├── vhdx (hard drive files for each distro)
                │   ├── aa
                │   ├── ops
                │   └── template
                └── wsl_bootstrap (this repo)
                    ├── logs
                    └── scripts
```
To create this directory structure, run the following commands and checkout this repo in wsl_bootstrap:
```
cd $HOME;mkdir -Force $HOME\wsl\tar;mkdir -Force $HOME\wsl\vhdx;mkdir -force $HOME\wsl\wsl_bootstrap;cd $HOME\wsl
```
Some wsl commands:
```
# make a directory for the .vhdx file and import a distro
mkdir -p ..\vhdx\ops 
wsl --import -d ops ..\vhdx\ops ..\tar\ops.tar

# list all installed distros
wsl -l

# launch a specific distro
wsl -d ops

# remove a distro and its hard drive file (vhdx)
wsl --unregister -d template

# export a wsl distro to a tar file for copying to another machine
wsl --export -d ops ../tar/ops.tar

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

## Prepare a base image
Start your wsl again to enter it with wsl_bootstrap as the current directory. If you're root, su to your chosen username  (for instance su - di) and navigate to the wsl_bootstrap directory.

We'll use this template image as a base for subsequent distros. Upgrade the template image with aptupgrade (and nukesnap) to save some diskspace and reduce time to create other distros. This will also give yourself passwordless sudo and set your user (di) as the default wsl user.

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
Example: Install the preset omega, add docker, and execute automatically:
```
. bs.sh y omega docker
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
You should find yourself within the new distro in the wsl_bootstrap directory, now we're ready to install configurations and some tools with the bs.sh script. Let's install the "kubernetes" preset.

```
# di@AA-IMC-9709427:/mnt/c/Users/aa303/wsl/wsl_bootstrap$ 
. bs.sh y kubernetes
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

## mounts and config from windows in the produced distro

We have provisioned the distro with a couple of scripts you can run in your home directory:
### mount_network_drives.sh

This script will attempt to get all network drives from Windows Powershell, create entries in /etc/fstab, and mount them in /mnt

### winconfig.sh
This script will copy the .ssh directory and .gitconfig file from Windows if they exist. Suggestions for other migrations are welcome :)