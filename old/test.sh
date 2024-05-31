#!/usr/bin/env sh
inp=$1
availableactionsstring="winconfig terraform k9s az brew oc kubectl krew noaptupdate nonukesnap"
if [[ $inp == "all" ]];then
    inp=$(echo $availableactionsstring |sed 's/noaptupdate\|nonukesnap//g' )
    # echo "all -> $inp"
fi
inp=$(echo $inp |sed 's/ +/ /g' )
printf "Running the following:\n$inp\nenter to accept"
read