#!/usr/bin/bash
homedir=$(wslpath $(powershell.exe -c 'write-host $env:USERPROFILE'))
printf "\nwsl path to windows home directory: %s\n" $homedir
if [ ! -d $homedir ]; then
    printf "\nPath $homedir doesn't exist\n"
    printf "\nquitting\n"
    return 2 &>/dev/null||exit
fi
homebasename=$(basename $homedir)
if [ ! -e ~/$homebasename ]; then
  ln -s $homedir ~
  printf "\ncreated link %s -> %s " "~/$homebasename" "$homedir\n"
fi

if [ ! -d $homedir/.ssh ]; then 
  printf "\n%s doesn't exist, seems like you don't have any keys\n" "${homedir}/.ssh"
else
  if [ -d ~/.ssh ]; then
    printf "\n~/.ssh already exists. You can use the following commands to copy any keys from windows, overwriting existing ones:\n"
    printf "\ncp -rv %s ~/.ssh; chmod -R 700 ~/.ssh\n" "${homedir}/.ssh\n"
  else
    cp -rv $homedir/.ssh ~/.ssh
    chmod -R 700 ~/.ssh
  fi
fi
  
if [ -e $homedir/.gitconfig ]; then 
  if [ -e ~/.gitconfig ]; then 
  printf "\n~/.gitconfig already exists, you can copy it again with this command:\n"
  printf "\ncp -v $homedir/.gitconfig ~\n"
  else
  printf "\ncopying .gitconfig to ~\n"
  cp -v $homedir/.gitconfig ~
  fi
else 
  printf "\n${homedir}/.gitconfig doesn't exist\n"
fi
printf "\n"