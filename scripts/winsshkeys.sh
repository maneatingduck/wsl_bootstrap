#!/usr/bin/env sh
# desc: Excluded by default if not explicitly requested. Copies ssh keys from windows, treat your tar file as a secret if using this. 
# get ssh keys
# winuser=$(cmd.exe /c "echo %USERNAME%")
winuser=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:UserName")
winuser=$(echo $winuser|sed 's#\r##g')
echo "windows user name '$winuser'"

cd ~
cp -rv $winuser/.ssh .
chmod 700 .ssh/id_rsa
