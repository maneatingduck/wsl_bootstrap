#!/usr/bin/bash

printf 'Getting driveletters\n'
#get and map drives
driveletters=$( powershell.exe -c 'get-smbmapping'|grep :|awk '{print tolower(substr($2,1,1))}') 
# for key in $( powershell.exe -c 'get-smbmapping'|grep :|awk '{print substr($2,1,1)}') 
for driveletter in $driveletters
do 
    mountdir="/mnt/$driveletter"
    driveletter_upper=$(echo "$driveletter" | tr '[:lower:]' '[:upper:]')
    if grep -iq "^${driveletter_upper}:" /etc/fstab ; then
        echo "${driveletter} is already mounted."
        continue
    fi
    echo Mapping $driveletter
    if [ -e $mountdir ] ;then
        if  [ ! -d $mountdir ] || [ "$( ls -A $mountdir )" ] ; then
            echo "dir ${mountdir} exists and is not an empty directory"
            continue
        fi
    else 
        echo creating mount dir $mountdir
        sudo mkdir -p $mountdir        
    fi
    fstab_line="${driveletter_upper}: ${mountdir} drvfs defaults 0 0"
    echo $fstab_line |sudo tee -a /etc/fstab

    if [ -e "~/${driveletter}" ]  ; then
        echo "~/${driveletter} already exists, not creating link"
    else
        echo "creating link ~/${driveletter} for /mnt/${driveletter}"
        ln -s /mnt/${driveletter} ~/${driveletter}
    fi

done
printf "\nMounting:\n"
sudo mount -av