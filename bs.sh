#!/usr/bin/bash
inp="$*"
dirname="$(realpath $(dirname "${BASH_SOURCE[0]}"))"
# inp="${i:-help}"
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == "0" ]]; then scriptname=$0;else scriptname=${BASH_SOURCE[0]};fi


debug=''
autoexec=''
help=''
if [[ $inp == "" ]]; then help=1;fi

inpspaces=" $(sed -E 's# +#  #g' <<<"$inp") "

m=" debug "
if [[ $inpspaces =~ $m ]]; then debug=1;printf 'debug: debug enabled\n'; fi


m=" autoexec "
if [[ $inpspaces =~ $m ]]; then autoexec=1;printf 'inf: autoexec enabled\n';fi


m=' autoexec | debug '
inpspaces=$(sed -E "s#$m##g"<<<"$inpspaces")
inpspaces=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$inpspaces")
inp=$inpspaces
# printf "'%s'\n" "$inpspaces"

# if [[ $sourced == "1" ]]; then return; else exit; fi
# printf "%s\n" "$inp"

#get available scripts
availableactionsstring="$(ls -1 scripts/*.sh|sed -E 's#scripts/(.*)\.sh#\1#'|tr '\n' ' '|sed 's# $##')"

[[ -v $debug ]] && printf 'debug: available actions: '%s'\n' "$availableactionsstring"

declare -A availableactions=()
# for s in $availableactionsstring
# IFS=" " read -ra a <<< $inp
for s in ${availableactionsstring// / }
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
    m="^([^ ]+) *: *(.*)$"
    if [[ ! $line =~ $m ]];then echo "warning: preset.txt: invalid line '$line'";continue;fi
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
    acts=""
    for a in ${actions// / };do
        # printf "preset is now '$preset'\n"
        # printf "action is now '$a'\n"
        # printf "preset $preset: testing action '$a'\n"
        # printf "'%s' '%s'\n" "${availableactions[$a]}" "$a"
        # if [[ -v "${availableactions["winsettings"]}" ]] 
        if [[ ! ${availableactions[$a]+"a"} == "a" ]]; 
        then 
            printf "warning: preset.txt: '%s': action '%s' not in available actions\n" "$preset" "$a"
            help=1
        else
            acts="$acts $a"
        fi
    done
    # printf "$preset : '$actions'"
    acts=$(sed 's#^ ##' <<<"$acts")
    # s+=([$preset]=$acts)
    presets+=([$preset]=$(sed 's#^ ##' <<<"$acts"))
    [[ -v $debug ]] && printf "debug: preset.txt read preset '%s' with acts '%s'\n" "$preset" "$acts"
done < presets.txt
# add/replace all in presets
presets+=([all]=$availableactionsstring)

# remove winsshkeys from presets
for key in "${!presets[@]}"; do   
    m=" *winsshkeys( *)"
    a="${presets["$key"]}"
    if [[ $a =~ $m  ]];then
        # printf "Before remove '%s'\n" "${presets["$key"]}"
        presets["$key"]=$(sed -E "s#$m#\1#g;"<<<"${presets["$key"]}")
        printf "Removing winsshkeys from preset '%s', it must be included explicitly\n" "$key"
        # printf "after remove '%s'\n" "${presets["$key"]}"
    fi
done
# for key in ${!presets[@]}; do   echo "${key}, ${presets[${key}]}"; done

# get descriptions, prereqs, and postreqs
prereqs=()
declare -A prereqstrings=()
declare -A postreqstrings=()
# declare -A descriptions=()
while IFS= read -r line || [ -n "$line" ]; do
    line=$( tr '[:upper:]' '[:lower:]'<<<"$line")
    # line=$(sed 's#[\r\n]##' <<<$line) 
    line=${line//$'\r'/}
    line=${line//$'\n'/}
    m="scripts/([^\.]+)\.[^:]+:[# ]*([^ #]+): *(.*) *$"
    # echo $line
    if [[ ! $line =~ $m ]]; then printf "warning: documentation line '%s' does not match '$m'" "$line";fi
    a=${BASH_REMATCH[1]}
    t=${BASH_REMATCH[2]}
    v=${BASH_REMATCH[3]}
    [[ -v $debug ]] && printf "debug: documentation for action '%s' type '%s' value '%s'\n" "$a" "$t" "$v"
    if [[ $t == "desc" ]]; then availableactions[$a]=$v;continue;fi
    if [[ $t == "prereq" ]]; then prereqs+=("$a $v");prereqstrings["$a"]="${prereqstrings["$a"]} $v";continue;fi
    if [[ $t == "postreq" ]]; then postreqstrings["$a"]="${postreqstrings["$a"]} $v";continue;fi

done <<< "$(grep --color=never -ire '# *\(prereq\|desc\|postreq\) *: *' scripts/*.sh)"

# fix single-spacing
for key in "${!prereqstrings[@]}"; do   prereqstrings["$key"]=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"${prereqstrings["$key"]}"); done
for key in "${!postreqstrings[@]}"; do   postreqstrings[$key]=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"${postreqstrings[$key]}"); done

[[ -v $debug ]] && for key in "${!prereqstrings[@]}";do printf 'debug: prereqs: '%s' needs '%s'\n' "$key" "${prereqstrings["$key"]}";done
[[ -v $debug ]] && for key in "${!postreqstrings[@]}";do printf 'debug: postreqs: '%s' needs '%s'\n' "$key" "${postreqstrings["$key"]}";done


effectiveactions=""
for s in ${inp// / }
do
    if [[ ${presets[$s]+"a"} == "a" ]];then 
        printf "inf: preset requested, merging with input actions: '%s': '%s'\n" "$s" "${presets[$s]}"
        for a in ${presets[$s]// / } ;do effectiveactions="$effectiveactions $a ";done
    else
        effectiveactions="$effectiveactions $s "
    fi
done
[[ -v $debug ]] && printf 'debug: checking actions for prereqs\n'
n=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$effectiveactions")
for a in ${n// / } ;do
    if [[ ${prereqstrings[$a]+"a"} == "a"  ]];then 
        p=${prereqstrings["$a"]}
        for p2 in ${p// / };do
            m=" $p2 "
            if [[ ! $effectiveactions =~ $m ]];then
                printf "inf: %s needs prereq %s, adding it\n" "$a" "$p2"
                effectiveactions=" $p2 $effectiveactions"
            fi
        done
    fi
done
# sort actions so that prereqs are installed before postreqs
[[ -v $debug ]] && printf 'debug: sorting actions so that prereqs come first\n'
sorting=$effectiveactions
sortedactions=""
while [[ $sorting != "$sortedactions" ]]
do
    sortedactions=$sorting
    n=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$sorting")
    for d in ${n// / } ;do
        if [[ ${prereqstrings[$d]+"a"} == "a" ]];then 
            n2=${prereqstrings["$d"]}
            for r in ${n2// / };do
                # printf 'sort:%s\n' "$effectiveactions"
                # printf 'sort: swapping %s and %s\n' "$d" "$r"
                # printf "sorting:   %s\n" "$sorting"
                sorting=$(sed -E "s#( $d )( .+ ){0,1}( $r )#\3\2\1#g" <<<"$sorting")
                # printf "sorted:    %s\n" "$sorting"
            done
        fi
    # if [[ ${postreqstrings[$d]+"a"} == "a" ]];then 
    #     n2=${postreqstrings["$d"]}
    #     for r in ${n2// / };do
    #         # printf 'sort:%s\n' "$sorting"
    #         # printf 'sort: swapping %s and %s\n' "$d" "$r"
    #         # printf "sorting:   %s\n" "$sorting"
    #         sorting=$(sed -E "s#( $d )( .+ ){0,1}( $r )#\3\2\1#g" <<<"$sorting")
    #         # printf "sorted:    %s\n" "$sorting"
    #     done
    # fi
    done
    # for r in "${rawdeps[@]}"
    # do
    #     echo "dep: $r"
    #     IFS=" " read -ra rp <<< $r
    #     echo "dep 0: ${rp[0]} 1: ${rp[1]}"
    #     echo "sorting:  $sorting"
    #     sorting=$(sed -E "s#( ${rp[1]} )( .+ ){0,1}( ${rp[0]} )#\3\2\1#g" <<<$sorting)
    #     echo "sorted:   $sorting"
    # done
done

[[ -v $debug ]] && printf 'debug: checking actions for postreqs\n'
effectiveactions=$(sed -E 's#\s+#  #g;s# *$|^ *# #g'<<<"$sortedactions")
# printf "'%s'\n" "$effectiveactions"
#add postreqs, they go last
n=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$effectiveactions")
for a in ${n// / } ;do
    if [[ ${postreqstrings[$a]+"a"} == "a"  ]];then 
        p=$(sed 's#\s+# #g;s# $|^ ##g' <<<${postreqstrings["$a"]})
        for p2 in ${p// / };do
            m=" $p2 "
            if [[ ! $effectiveactions =~ $m ]];then
                printf "inf: %s needs postreq %s, adding it\n" "$a" "$p2"
                effectiveactions="$effectiveactions $p2 "
            else
                printf "inf: putting postreq '%s' last\n" "$p2" 
                effectiveactions="$(sed "s#$m##g" <<<  "$effectiveactions") $m "
            fi
        done
    fi
done    

#add aptupgrade and cleanapt as mandatory
# printf 'effectiveactions %s\n' "$effectiveactions"
# if [[ -z "$effectiveactions" ]];then
    # effectiveactions="$(sed -E 's# aptupgrade | cleanapt ##g'<<<"$effectiveactions")"
    # effectiveactions=" aptupgrade $effectiveactions cleanapt "
    # printf 'added/moved aptupgrade and cleanapt to first/last respectively.'
# fi




if [[ -z $effectiveactions ]];then  
    help=1
    [[ -v $debug ]] && printf 'debug: empty input, show help and exit\n'
else 
        effectiveactions="$(sed -E 's# aptupgrade | cleanapt ##g'<<<"$effectiveactions")"
    effectiveactions=" aptupgrade $effectiveactions cleanapt "
    printf 'added/moved aptupgrade and cleanapt to first/last respectively.\n'
fi
effectiveactions="$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$effectiveactions")"
printf "inf: effective actions: '%s'\n" "$effectiveactions"

# help=1
if [[ $help == 1 ]]; then
    #  printf "input: '%s'" "${!inputarray[@]}"
    printf "\nUsage: %s <space separated list of actions or presets>\n\n" "$scriptname"
    printf "This script will install your selection of utilities in a wsl Ubuntu distro.\n"
    printf "It will also run apt update/upgrade.\n\n"
    # printf  "available actions: '$availableactionsstring'\n\n"
    
    printf "Available presets:\n\n"
    l="$(printf '%s\n' "${!presets[@]}"|wc -L)"
    k="$(printf '%s\n' "${!presets[@]}"|sort)"
    for p in $k
    do
        printf "%s:" "$p";printf %*s'' $((18 +2 - ${#p}));printf "%s\n" "${presets[$p]}" 
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
    k="$(printf '%s\n' "${!availableactions[@]}"|sort)"
    # for s in "${!availableactions[@]}"
    for s in $k
    do
        printf "%s:" "$s";printf %*s'' $((18 +2 - ${#s}));printf '%s\n' "${availableactions[${s}]}" 
        
        # printf "$s:"; printf %*s'' $((20 - ${#s})) ; printf "%s\n" "$(grep -E "^#" scripts/$s.sh |grep -v "^#!/" |head -n 1|sed -E 's#^[#\s]+##')"
    done
    printf "\n"
    if [[ $sourced == "1" ]]; then return; else exit; fi
fi
# if [[ $sourced == "1" ]]; then return; else exit; fi
# printf 'dollar0 '%s' realpath dirname '%s' bash_source '%s' \n'  "$0" "$(realpath $(dirname "$0"))" "${BASH_SOURCE[0]}"
# printf 'dollar0 '%s' realpath dirname '%s' bash_source '%s' \n'  "$0" "$(realpath $(dirname "${BASH_SOURCE[0]}"))" "${BASH_SOURCE[0]}"
# echo "The absolute directory of this script is: $(realpath $(dirname "$0"))/$0"
while [[ -z $autoexec  ]] ; do
    read -p "Execute? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) if [[ $sourced == "1" ]]; then return; else exit; fi;;
        * ) echo "Please answer (y)es or (n)o.";;
    esac
done

# if [[ $sourced == "1" ]]; then return; else exit; fi
printf '\nAuthorizing sudo: '
sudo ls >/dev/null
printf '\n'
# printf 'sudo apt update/upgrade\n'
declare -A outputs=()
allstart=$(($(date +%s%N)/1000000))
mkdir -p logs; rm logs/*
for a in ${effectiveactions// / };do 
    start=$(($(date +%s%N)/1000000))
   cd $dirname
   printf "Executing '%s'" "$a";
    (. ./scripts/$a.sh >logs/$a.txt 2>&1) && o="OK"||o="FAIL" 
    end=$(($(date +%s%N)/1000000))
    ms=$(($end-$start))
    # printf 'failtrain %s' "$o"
    os=$(printf '%s: ' "$o";printf %*s'' $((4 - ${#ms}));printf "%s ms" "$ms")
    outputs["$a"]=$(printf '%s' "$os")
    printf %*s'' $((20 - ${#a}));printf "%s\n" "$os"
done
allend=$(($(date +%s%N)/1000000))
allms=$(($allend-$allstart))
printf '\nAll done in %s ms \n\n' "$allms"

#  k="$(printf '%s\n' "${!outputs[@]}"|sort)"
# for s in $k
# do
#     printf "%s:" "$s";printf %*s'' $((18 +2 - ${#s}));printf '%s\n' "${outputs[${s}]}" 
    
# done

. ~/.bashrc