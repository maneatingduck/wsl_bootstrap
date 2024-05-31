#!/usr/bin/env sh
# desc: copies settings such as gitconfig from windows
# winuser=$(cmd.exe /c "echo %USERNAME%")
winuser=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:UserName")
winuser=$(echo $winuser|sed 's#\r##g')
echo "windows user name '$winuser'"

cd ~
ln -nsf /mnt/c/Users/$winuser/
cp -rv $winuser/.gitconfig .

