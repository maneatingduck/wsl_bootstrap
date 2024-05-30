#!/usr/bin/bash
i="$*"
i="${i:-help}"
inp 
# printf "%s\n" "$inp"
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == "0" ]]; then scriptname=$0;else scriptname=${BASH_SOURCE[0]};fi

#get available scripts
availableactionsstring="$(ls -1 scripts/*.sh|sed -E 's#scripts/(.*)\.sh#\1#'|tr '\n' ' '|sed 's# $##')"
# echo "'$availableactionsstring'"
declare -A availableactions=()
for s in $availableactionsstring
do
    availableactions+=(["$s"]="")
done
# for key in ${!availableactions[*]}; do   echo "$key"; done
# for key in ${!availableactions[@]}; do   echo "${key}, ${availableactions[${key}]}"; done
# for key in ${!availableactions[@]}; do   echo "'${key}'"; done

# TODO: add spaces to all action strings for processing
# TODO*: check that all selected and preset actions are available as scripts
# TODO*: dynamic prereqs from comment in install script: grep --color=never -ire "# *prereq *: *" scripts/|sed -E 's#^[^/]+/([^\.]+).*: *([^\s]+)+ *#\1 \2#'
# TODO*: presets from file

declare -A presets=()
# read presets
while IFS= read -r line || [ -n "$line" ]; do
    # echo $line
    line=$(sed 's#[\r\n]##' <<<$line) 
    m="^([^ ]+):(.*)$"
    if [[ ! $line =~ $m ]];then echo "preset.txt: invalid line '$line'";continue;fi
    preset=${BASH_REMATCH[1]}
    actions=${BASH_REMATCH[2]}
    # echo "processing line $line"
    # line=$(sed 's#[\r\n]##' <<<$line) 
    # # printf "line is now '$line'\n"
    # # preset=$(sed 's#:.*##g' <<<$line)
    # # actions=$(sed 's#.*:##g'<<<$line)
    # IFS=":" read -ra ra <<<$line
    # preset=${ra[0]}
    # actions=${ra[1]}
    # echo "'${actions}'" 
    # for a in $actions ; do
    for a in ${actions// / };do
        # printf "preset is now '$preset'\n"
        # printf "action is now '$a'\n"
        # printf "preset $preset: testing action '$a'\n"
        if [[ ! ${availableactions[$a]+"a"} == "a" ]]; then printf "WARNING: preset.txt: '%s': action '%s' not in available actions\n" "$preset" "$a";fi
    done
    # printf "$preset : '$actions'"
    presets+=([$preset]=$actions)
done < presets.txt
# add/replace
presets+=([all]=$availableactionsstring)
# for key in ${!presets[@]}; do   echo "${key}, ${presets[${key}]}"; done

# get descriptions and prereqs
prereqs=()
# declare -A descriptions=()
while IFS= read -r line || [ -n "$line" ]; do
    line=$( tr '[:upper:]' '[:lower:]'<<<$line)
    line=$(sed 's#[\r\n]##' <<<$line) 
    m="scripts/([^\.]+)\.[^:]+:[# ]*([^ #]+): *(.*) *$"
    # echo $line
    if [[ ! $line =~ $m ]]; then printf "documentation line '%s' does not match '$m'" "$line";fi
    a=${BASH_REMATCH[1]}
    t=${BASH_REMATCH[2]}
    v=${BASH_REMATCH[3]}
    # printf "action '$a' type '$t' value '$v'\n"
    if [[ $t == "desc" ]]; then availableactions[$a]=$v;continue;fi
    if [[ $t == "prereq" ]]; then prereqs+=("$a $v");continue;fi

done <<< "$(grep --color=never -ire '# *\(prereq\|desc\) *: *' scripts/*.sh)"
# for key in "${!availableactions[@]}"; do   echo "${key}, ${availableactions[${key}]}"; done
# for key in "${!prereqs[@]}"; do   echo "${key}, ${prereqs[${key}]}"; done

if [[ $inp =~ "help" ]]; then
    # check if script is sourced
    
    printf "\nUsage: %s \"<space separated list of actions or presets>\"\n\n" "$scriptname"
    printf "This script will install your selection of utilities in a wsl Ubuntu distro.\n"
    printf "It will also run apt update/upgrade.\n\n"
    # printf  "available actions: '$availableactionsstring'\n\n"
    
    printf "Available presets:\n\n"
    l="$(printf '%s\n' "${!presets[@]}"|wc -L)"
    for p in "${!presets[@]}"
    do
        printf "%s:" "$p";printf %*s'' $((18 +2 - ${#p}));printf '%s\n' "${presets[$p]}" 
        # printf "'%s': %s\n" "$p" "${presets[$p]}"
    done
    # for the documentation feature to work, add a second commented line after #!/usr/bin/bash in the action script 
    # this will be shown to the user:
    #!/usr/bin/bash
    # installs k3d, a k3s management utility. Prereq: brew

    printf "\nAvailable actions:\n\n"
    # for s in ${availableactionsstring// / }
    # do
    #     printf "$s:"; printf %*s'' $((20 - ${#s})) ; printf "%s\n" "$(grep -E "^#" scripts/$s.sh |grep -v "^#!/" |head -n 1|sed -E 's#^[#\s]+##')"
    # done
    l="$(printf '%s\n' "${!availableactions[@]}"|wc -L)"
    for s in "${!availableactions[@]}"
    do
        printf "%s:" "$s";printf %*s'' $((18 +2 - ${#s}));printf '%s\n' "${availableactions[${s}]}" 
        # printf "$s:"; printf %*s'' $((20 - ${#s})) ; printf "%s\n" "$(grep -E "^#" scripts/$s.sh |grep -v "^#!/" |head -n 1|sed -E 's#^[#\s]+##')"
    done
    printf "\n"
    if [[ $sourced == "1" ]]; then return; else exit; fi
fi

if [[ $sourced == "1" ]]; then return; else exit; fi


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

# sort actions so that prerews (ie brew) are installed before dependant action (ie k3d)
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