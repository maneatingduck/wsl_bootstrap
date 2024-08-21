# Overview
These scripts are intended to help you create and setup wsl installations for use with VMs that have no connection to internet and Linux repos. 

After running the setup scripts (bs.sh and/or individual scripts) you can export the distro to a tar file, copy it to your VM, and import it into your VMs WSL instance.

# WSL version(s) and installation
We'll assume that you start with no wsl installed.
The import/exports should work with any WSL 2 installation, but I prefer the (currently) pre-release WSL versions found at https://github.com/microsoft/WSL/releases

# Preparation and defaults

To get a clean ubuntu template image we'll reinstall the default Ubuntu image. This example will use "di" as the distro name and username. The password can be "di" as well, in a wsl installation you can always get root by launching wsl -u root, so this is not an additional security risk.

powershell:
```
wsl --unregister Ubuntu
wsl --install
# username: di

```
You'll end up in the user's home directory in the new distro. Exit with the command "exit"

## prepare a base image
Start your wsl again to enter it with wsl_bootstrap as the current directory.  

Run the following to give yourself passwordless sudo and set the di user as the default wsl user. When doing this you need to enter the user di's password:
```
# Make sure your user is the default wsl user, as an imported image won't have the correct registry key set. 
printf '\n[user]\ndefault=%s\n' $USER | sudo tee -a /etc/wsl.conf
# Also add your user to sudoers with no password
printf '\n%s ALL=(ALL) NOPASSWD: ALL\n' $USER | sudo tee -a /etc/sudoers
```

You can upgrade the base image with aptupgrade (and nukesnap) to save some diskspace and reduce time for subsequent distro images:
```
# di@AA-IMC-9709427:/mnt/c/Users/aa303/wsl/wsl_bootstrap$
. bs.sh y aptupgrade nukesnap
```
Now we'll store this image as a template, which we'll use to create other images. We'll also remove the ubuntu image to save on disk space.
Exit wsl with the command "exit", make a backup tar file:
```
# PS C:\Users\aa303\wsl\wsl_bootstrap> 
wsl --export -d ubuntu ..\tar\template.tar
wsl --unregister ubuntu
```
You now have a template.tar in the directory wsl\tar which we can use to create more images

## Creating a deployable image for local kubernetes

I prefer to use very short distro names (such as aa for aa, o for omega and so on)

```
# PS C:\Users\aa303\wsl\wsl_bootstrap> 
mkdir -Force ..\vhdx\aa
wsl --import -d aa ..\vhdx\aa ..\tar\template.tar
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
You should find yourself within the new distro in the wsl_bootstrap directory, now we're ready to install configurations and some tools with the bs.sh script. Let's install the "local_kubernetes" preset.

```
# di@AA-IMC-9709427:/mnt/c/Users/aa303/wsl/wsl_bootstrap$ 
. bs.sh y omega
```


```
.
├── tar
├── vhdx
│   ├── di
│   └── u1
└── wsl_bootstrap
    ├── logs
    ├── old
    └── scripts
```