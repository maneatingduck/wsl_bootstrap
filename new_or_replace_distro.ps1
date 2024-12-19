Param ([string]$distroname,[string]$tarpath)  

$exit=$false
$confirm=$false
write-host ""
if(-not $distroname) {$distroname="template";write-host "-distroname not supplied, using $distroname`n" ;}
if(-not $tarpath) {$tarpath="..\tar\template.tar";write-host "-tarpath not supplied, using $tarpath`n" ;}
if(-not (Test-Path $tarpath -PathType Leaf)) {write-host "File $tarpath doesn't exist";$exit =$true}
$tarfile = get-item $tarpath
$vhdxpath="..\vhdx\$distroname"
if($exit)
{
    $scriptname=${MyInvocation}.ScriptName    
    write-host "Usage:"
    write-host "$scriptname <distroname> <path-to-tar-file"
}
If ((Get-ChildItem -Path $vhdxpath -Force | Measure-Object).Count -ne 0)
    {write-host "vhdx directory $vhdxpath exists and is not empty`n";$confirm=$true}
if(wsl -l |Where {$_.Replace("`0","") -match '^distroname$'})
    {write-host "distro $distroname exists in wsl`n";$confirm=$true}

write-host "importing ${tarfile} to distro $distroname`n"
if($confirm)
{write-host "Press enter to continue, Ctrl+C or any other key to exit";$continue = read-host }
else {$continue=""}
if($continue -eq "")
{
write-host  removing $distroname 
wsl --unregister $distroname
write-host  seeding $distroname from $tarpath
if(wsl -l |Where {$_.Replace("`0","") -match '^test2'}) {write-host haha no it exists;exit;}
# if(Test-Path ..\vhdx\$distroname ){Write-Host ..\vhdx\$distroname already exists, exiting ;exit}
$d=mkdir -f ..\vhdx\$distroname
# rm -Recurse $d\*
echo "wsl --import $distroname $vhdxpath $tarfile"
wsl --import $distroname $vhdxpath $tarfile
wsl -d $distroname 
}