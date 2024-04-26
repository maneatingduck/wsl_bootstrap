#!/usr/bin/env sh
# get ssh keys
cd ~
ln -s /mnt/c/Users/$WINDOWS_USER/
cp -rv $WINDOWS_USER/.ssh .
cp -rv $WINDOWS_USER/.gitconfig .
chmod 700 .ssh/id_rsa
cat << \EOF >> ~/.bashrc
if  type "conemuc.exe" 2&>/dev/null; then
  PROMPT_COMMAND='type conemuc.exe >/dev/null&& ConEmuC.exe -StoreCWD `echo "${PWD#"${PWD%/*/*}/"}"`'
fi
if [[ -n "${ConEmuPID}" ]]; then
  PS1="$PS1\[\e]9;9;\"\w\"\007\e]9;12\007\]"
fi
export PS1="@\$WSL_DISTRO_NAME:\[\033[32m\]\w\[\033[33m\]\$(GIT_PS1_SHOWUNTRACKEDFILES=1 GIT_PS1_SHOWDIRTYSTATE=1 GIT_PS1_DESCRIBE_STYLE=branch GIT_PS1_SHOWCOLORHINTS=1 __git_ps1)\[\033[00m\]$ "
EOF


# export PS1="@\$WSL_DISTRO_NAME:\[\033[32m\]\w\[\033[33m\]\$(GIT_PS1_SHOWUNTRACKEDFILES=1 GIT_PS1_SHOWDIRTYSTATE=1 __git_ps1)\[\033[00m\]$ "
# export PS1="@\$WSL_DISTRO_NAME:\[\033[32m\]\w\[\033[33m\]\$(GIT_PS1_SHOWUNTRACKEDFILES=1 __git_ps1)\[\033[00m\]$ "
