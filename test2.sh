#!/usr/bin/bash
inp="$*"
# inp="${i:-help}"
help=0
if [[ $inp == "" ]]; then help=1;fi

# printf "%s\n" "$inp"
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == "0" ]]; then scriptname=$0;else scriptname=${BASH_SOURCE[0]};fi

#get available scripts
availableactionsstring="$(ls -1 scripts/*.sh|sed -E 's#scripts/(.*)\.sh#\1#'|tr '\n' ' '|sed 's# $##')"
# echo "'$availableactionsstring'"
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
    acts=""
    for a in ${actions// / };do
        # printf "preset is now '$preset'\n"
        # printf "action is now '$a'\n"
        # printf "preset $preset: testing action '$a'\n"
        if [[ ! ${availableactions[$a]+"a"} == "a" ]]; 
        then 
            printf "WARNING: preset.txt: '%s': action '%s' not in available actions\n" "$preset" "$a";help=1
        else
            acts="$acts $a"
        fi
    done
    # printf "$preset : '$actions'"
    presets+=([$preset]=$(sed 's#^ ##' <<<"$acts"))
done < presets.txt
# add/replace
presets+=([all]=$availableactionsstring)
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
    if [[ ! $line =~ $m ]]; then printf "documentation line '%s' does not match '$m'" "$line";fi
    a=${BASH_REMATCH[1]}
    t=${BASH_REMATCH[2]}
    v=${BASH_REMATCH[3]}
    # printf "action '%s' type '%s' value '%s'\n" "$a" "$t" "$v"
    if [[ $t == "desc" ]]; then availableactions[$a]=$v;continue;fi
    if [[ $t == "prereq" ]]; then prereqs+=("$a $v");prereqstrings["$a"]="${prereqstrings["$a"]} $v";continue;fi
    if [[ $t == "postreq" ]]; then postreqstrings["$a"]="${postreqstrings["$a"]} $v";continue;fi

done <<< "$(grep --color=never -ire '# *\(prereq\|desc\|postreq\) *: *' scripts/*.sh)"

# fix single-spacing
for key in "${!prereqstrings[@]}"; do   prereqstrings["$key"]=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"${prereqstrings["$key"]}"); done
for key in "${!postreqstrings[@]}"; do   postreqstrings[$key]=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"${postreqstrings[$key]}"); done

# for key in "${!availableactions[@]}"; do   echo "${key}, ${availableactions[${key}]}"; done
# printf "prereqstrings\n";for key in "${!prereqstrings[@]}"; do   printf "'%s', '%s'\n" "$key" "${prereqstrings[${key}]}"; done
# printf "postreqstrings\n";for key in "${!postreqstrings[@]}"; do   printf "'%s', '%s'\n" "$key" "${postreqstrings[${key}]}"; done
    
# TODO: check if all input is in available actions or presets
#build input from input and presets

# declare -A inputarray=()
effectiveactions=""
for s in ${inp// / }
do
    if [[ ${presets[$s]+"a"} == "a" ]];then 
        # for a in ${presets[$s]// / } ;do ${inputarray[$a]=""};done
        for a in ${presets[$s]// / } ;do effectiveactions="$effectiveactions $a ";done
    else
        effectiveactions="$effectiveactions $s "
    fi
done
# e=$effectiveactions
# printf "prereqs #1\n"
n=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$effectiveactions")
for a in ${n// / } ;do
    if [[ ${prereqstrings[$a]+"a"} == "a"  ]];then 
        p=${prereqstrings["$a"]}
        for p2 in ${p// / };do
            m=" $p2 "
            if [[ ! $effectiveactions =~ $m ]];then
                printf "%s needs prereq %s, adding it\n" "$a" "$p2"
                effectiveactions=" $p2 $effectiveactions"
            fi
        done
    fi
done
# sort actions so that prereqs are installed before postreqs
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
                printf "%s needs postreq %s, adding it\n" "$a" "$p2"
                effectiveactions="$effectiveactions $p2 "
            else
                printf "putting postreq '%s' last\n" "$m" 
                effectiveactions="$(sed "s#$m##g" <<<  "$effectiveactions") $m "
            fi
        done
    fi
done    
# printf 'effectiveactions #1: %s\n' "$effectiveactions"

# effectiveactions=$e
# printf "prereqs #2\n"
# for p in "${!prereqs[@]}"; do
#     # echo "$p";
#     m="([^ ]+) ([^ ]+)"
#     if [[ $p =~ $m ]];then 
#         d=${BASH_REMATCH[1]}
#         r=${BASH_REMATCH[2]}
#         m=" $d "
#         m2=" $r "
#         if [[ $effectiveactions =~ $m && ! $effectiveactions =~ $m2 ]]; then
#             printf "%s needs %s, adding it\n" "$d" "$r"
#             effectiveactions=" $r $effectiveactions"
#         fi
#     fi
# done
# printf 'effectiveactions #2: %s\n' "$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$effectiveactions")"
# echo "$effectiveactions";


# for key in "${!inputarray[@]}"; do   echo "${key}, ${inputarray[${key}]}"; done
help=1
if [[ $help == 1 ]]; then
    #  printf "input: '%s'" "${!inputarray[@]}"
    printf "Effective actions: %s" "$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$effectiveactions")"
    printf "\nUsage: %s \"<space separated list of actions or presets>\"\n\n" "$scriptname"
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