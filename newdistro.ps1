$distroname=$args[0]
# echo $distroname
# exit
if(-not $distroname) {exit;}
$templatetar = "template.tar"
write-host  seeding $distroname from $templatetar
if(wsl -l |Where {$_.Replace("`0","") -match '^test2'}) {write-host haha no it exists;exit;}
# if(Test-Path ..\vhdx\$distroname ){Write-Host ..\vhdx\$distroname already exists, exiting ;exit}
$d=mkdir -f ..\vhdx\$distroname
# rm -Recurse $d\*
wsl --import $distroname ..\vhdx\$distroname ..\wsltar\$templatetar
wsl -d $distroname