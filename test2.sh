#!/usr/bin/bash
inp="${1:-help}"
#get available scripts
availableactionsstring="$(ls -1 scripts/*.sh|sed -E 's#scripts/(.*)\.sh#\1#'|tr '\n' ' '|sed 's# $##')"

#TODO: check that all selected and preset actions are available as scripts
#TODO: dynamic prereqs

declare -A presets=(
["all"]=$availableactionsstring 
["openshift"]="winconfig k9s az oc kubectl krew tsh k3d jq brew" 
["openshifttf"]="winconfig terraform k9s az oc kubectl krew docker tsh k3d jq brew" 
["key3"]="value3"
)
if [[ $inp =~ "help" ]]; then
    # check if script is sourced
    (return 0 2>/dev/null) && sourced=1 || sourced=0
    if [[ $sourced == "0" ]]; then scriptname=$0;else scriptname=${BASH_SOURCE[0]};fi

    printf "Usage: $scriptname \"<space separated list of actions or presets>\"\n\n"
    printf "This script will install your selection of utilities in wsl.\n"
    printf "It will also remove snap and run apt update/upgrade.\n\n"
    # printf  "available actions: '$availableactionsstring'\n\n"
    
    printf "availabple presets:\n\n"
    for p in ${!presets[@]}
    do
        printf "'$p': ${presets[$p]}\n"
    done
    # for the documentation feature to work, add a second commented line after #!/usr/bin/bash in the action script 
    # this will be shown to the user:
    #!/usr/bin/env sh
    # installs k3d, a k3s management utility. Prereq: brew

    printf "\nAvailable actions:\n\n"
    for s in ${availableactionsstring// / }
    do
        printf "$s:"; printf %*s'' $((20 - ${#s})) ; printf "$(grep -E "^#" scripts/$s.sh |head -n 2|tail -n 1|sed -E 's#^[#\s]+##')\n"
    done

    printf "\n"
    if [[ $sourced == "1" ]]; then return; else exit; fi
fi
inpspaces=" $(sed -E 's# +#  #g' <<<"$inp") "
for p in ${!presets[@]}
do
    # echo "checking preset $p"
    if [[ $inp == $p ]];then 
        inp=${presets[$p]}
        echo "input '$p', selecting '$inp'"
    fi
done
echo "actions: '$inp'"



# get available scripts from script directory

# availableactionsstring = $(ls -1 scripts|sed 's#\.sh# #'|tr '\n' ' ')
echo "'$availableactionsstring'"
# echo "iterating inputs"
# for i in ${inp// / }
# do
#     echo "$i"
# done


IFS="," read -ra rawdeps <<< "brew krew,brew k9s,brew kubectl,brew k3d"


echo "rawdeps ${rawdeps[*]}"
# add single spaces before and after actions to simplify matching
sorting=" $(sed -E 's# +#  #g' <<<"$inp") "

# adding prereqs if they are missing
for r in "${rawdeps[@]}"
do
    IFS=" " read -ra rp <<< $r
    # printf "checking dep $r\n"
    if [[ $sorting =~ " ${rp[1]} " && ! $sorting =~ " ${rp[0]} " ]]; then 
        echo "${rp[1]} needs ${rp[0]}, adding it"
        sorting="$sorting  ${rp[0]}"
    fi
done
unsorted=$sorting
echo "sort start: '$sorting'"
sortedactions=""


while [[ $sorting != $sortedactions ]]
do
    sortedactions=$sorting
    for r in "${rawdeps[@]}"
    do
        echo "dep: $r"
        IFS=" " read -ra rp <<< $r
        echo "dep 0: ${rp[0]} 1: ${rp[1]}"
        echo "sorting:  $sorting"
        sorting=$(sed -E "s#( ${rp[1]} )( .+ ){0,1}( ${rp[0]} )#\3\2\1#g" <<<$sorting)
        echo "sorted:   $sorting"
    done
done

echo "unsorted: '$unsorted'"
echo "sorted:   '$sortedactions'"
# remove superfluous spaces
sortedactions=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<$sortedactions)
echo "sorted_ns:'$sortedactions'"
# if [[ $inp == "all" ]];then
#     inp=$(echo $availableactionsstring |sed 's/noaptupdate\|nonukesnap//g' )
#     # echo "all -> $inp"
# fi
# inp=$(echo $inp |sed 's/ +/ /g' )
# printf "Running the following:\n$inp\nenter to accept"
# read