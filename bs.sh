#!/usr/bin/bash
inp="$*"
dirname="$(realpath $(dirname "${BASH_SOURCE[0]}"))"
# inp="${i:-help}"
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == "0" ]]; then scriptname=$0;else scriptname=${BASH_SOURCE[0]};fi

# process special actions
debug=''
autoexec=''
help=''
noapt=''
if [[ $inp == "" ]]; then help=1;fi

# process special options
inpspaces=" $(sed -E 's# +#  #g' <<<"$inp") "
m=" help | --help "
if [[ $inpspaces =~ $m ]]; then help=1;printf 'inf: help requested\n'; fi

m=' debug '
if [[ $inpspaces =~ $m ]]; then debug=1;printf 'debug: debug enabled\n'; fi

m=" noapt "0
if [[ $inpspaces =~ $m ]]; then noapt=1;printf 'debug: noapt -- don''t add aptupgrade automatically\n'; fi

m=" autoexec "
if [[ $inpspaces =~ $m ]]; then autoexec=1;printf 'inf: autoexec enabled\n';fi

m=' autoexec | debug | noapt '
inpspaces=$(sed -E "s#$m##g"<<<"$inpspaces")
inpspaces=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$inpspaces")
inp=$inpspaces

#get available scripts
availableactionsstring="$(ls -1 scripts/*.sh|sed -E 's#scripts/(.*)\.sh#\1#'|tr '\n' ' '|sed 's# $##')"

[[ -v $debug ]] && printf 'debug: available actions: '%s'\n' "$availableactionsstring"

# make an array of available actions for processing
declare -A availableactions=()
for s in ${availableactionsstring// / }
do
    availableactions+=(["$s"]="")
done

# read presets
declare -A presets=()
while IFS= read -r line || [ -n "$line" ]; do
    m="^[^:]*#"
    if [[ $line =~ $m ]]; then continue; fi
    line=$(sed 's#[\r\n]##' <<<$line) 
    m="^([^ ]+) *: *(.*)$"
    if [[ ! $line =~ $m ]];then echo "WARNING>: preset.txt: invalid line '$line'";continue;fi
    preset=${BASH_REMATCH[1]}
    actions=${BASH_REMATCH[2]}
    acts=""
    for a in ${actions// / };do
            acts="$acts $a"
    done
    acts=$(sed 's#^ ##' <<<"$acts")
    presets+=([$preset]=$(sed 's#^ ##' <<<"$acts"))
    [[ -v $debug ]] && printf "debug: preset.txt imported preset '%s' with acts '%s'\n" "$preset" "$acts"
done < presets.txt

# add/replace "all" in presets
presets+=([all]=$availableactionsstring)

# validate preset actions against available actions and other presets
for p in "${!presets[@]}"; do   
    actions="${presets["$p"]}"
    for a in ${actions// / };do
        if [[ ${availableactions[$a]+"a"} != "a" && ${presets[$a]+"a"} != "a"  ]]; 
        then 
            printf "ERROR: preset.txt: '%s': action '%s' not in available actions or presets, please edit presets.txt\n" "$preset" "$a"
            help=1
        fi
  done    
done


#gather config information from script comments
prereqs=()
declare -A prereqstrings=()
declare -A postreqstrings=()
while IFS= read -r line || [ -n "$line" ]; do
    line=$( tr '[:upper:]' '[:lower:]'<<<"$line")
    line=${line//$'\r'/}
    line=${line//$'\n'/}
    m="scripts/([^\.]+)\.[^:]+:[# ]*([^ #]+): *(.*) *$"
    if [[ ! $line =~ $m ]]; then printf "WARNING: documentation line '%s' does not match '$m'" "$line";fi
    a=${BASH_REMATCH[1]}
    t=${BASH_REMATCH[2]}
    v=${BASH_REMATCH[3]}
    [[ -v $debug ]] && printf "debug: documentation for action '%s' type '%s' value '%s'\n" "$a" "$t" "$v"
    if [[ $t == "desc" ]]; then availableactions[$a]=$v;continue;fi
    if [[ $t == "prereq" ]]; then prereqs+=("$a $v");prereqstrings["$a"]="${prereqstrings["$a"]} $v";continue;fi
    if [[ $t == "postreq" ]]; then postreqstrings["$a"]="${postreqstrings["$a"]} $v";continue;fi

done <<< "$(grep --color=never -ire '# *\(prereq\|desc\|postreq\) *: *' scripts/*.sh)"

# convert presets to single-spacing
for key in "${!prereqstrings[@]}"; do   prereqstrings["$key"]=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"${prereqstrings["$key"]}"); done
for key in "${!postreqstrings[@]}"; do   postreqstrings[$key]=$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"${postreqstrings[$key]}"); done

[[ -v $debug ]] && for key in "${!prereqstrings[@]}";do printf 'debug: prereqs: '%s' needs '%s'\n' "$key" "${prereqstrings["$key"]}";done
[[ -v $debug ]] && for key in "${!postreqstrings[@]}";do printf 'debug: postreqs: '%s' needs '%s'\n' "$key" "${postreqstrings["$key"]}";done


# validate input against available actions and presets
effectiveactions=""
for s in ${inp// / }
  do
    if [[ ${availableactions[$s]+"a"} != "a" && ${presets[$s]+"a"} != "a" ]]; then
      help=1
      printf "ERROR: action '%s' not in available actions or presets\n" "$s"
      continue
    else
      m=" $s "
      if [[ ! $effectiveactions =~ $m ]];then 
        effectiveactions="$effectiveactions $s "
        [[ -v $debug ]] && printf 'debug: added action or preset %s\n' "$s"
      fi
    fi
done


# add actions from presets requested in inputs. Loop until equal, as presets can be nested
e="bah"
while [[ $e != "$effectiveactions" ]];do
  e=$effectiveactions
  for s in ${effectiveactions// / }
    do
        if [[ ${presets[$s]+"a"} == "a" ]];then 
            printf "inf: preset requested, merging with input actions: '%s': '%s'\n" "$s" "${presets[$s]}"
            for a in ${presets[$s]// / } ;do 
                m=" $a "
                if [[ ! $effectiveactions =~ $m ]]; then
                    effectiveactions="$effectiveactions $a ";
                    m=" $s "
                    effectiveactions="${effectiveactions//$m/}"
                fi
            done
        fi
    done
done

# add prereqs if necessary
[[ -v $debug ]] && printf 'debug: checking actions for prereqs\n'
e=""
while [[ $e != "$effectiveactions" ]]
do
    e=$effectiveactions
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
done
# sort actions so that prereq scripts are run before dependent scripts
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
                sorting=$(sed -E "s#( $d )( .+ ){0,1}( $r )#\3\2\1#g" <<<"$sorting")
            done
        fi
    done
done

[[ -v $debug ]] && printf 'debug: checking actions for postreqs\n'

# convert to space padding
effectiveactions=$(sed -E 's#\s+#  #g;s# *$|^ *# #g'<<<"$sortedactions")

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


    if [[ -z $effectiveactions ]];then  
        help=1
        [[ -v $debug ]] && printf 'debug: empty input, show help and exit\n'

    else
        # we always want to clean apt cache last

        aptu=""
        mc=" aptclean "
        effectiveactions="$(sed -E "s#$mc##g"<<<"$effectiveactions")"
        effectiveactions="${effectiveactions}${mc}"
        
        # ...and will put aptupgrade first, but won't add aptupgrade if explicitly requested not to
        ma=" aptupgrade "
        effectiveactions="$(sed -E "s#$ma##g"<<<"$effectiveactions")"
        if [[ -z $noapt ]];then
            aptu="aptupgrade, "
            effectiveactions="${ma}${effectiveactions}"
        fi
        [[ -v $help ]] && printf 'inf: added %saptclean\n' "$aptu"
      
    fi

effectiveactions="$(sed -E 's#\s+# #g;s# $|^ ##g'<<<"$effectiveactions")"
 [[ $effectiveactions ]] && 
printf "inf: effective actions: '%s'\n" "$effectiveactions"

if [[ $help == 1 ]]; then

    printf "\nUsage: %s <space separated list of actions or presets>\n\n" "$scriptname"
    printf "This script will install your selection of utilities in a wsl Ubuntu distro.\n"
    printf "It will also run apt update/upgrade.\n\n"
    printf "Special input actions:\n"
    printf "help/--help or no input: show usage. If help is mixed with input it will display processing information\n"
    printf "autoexec: execute without confirmation\n"
    printf "debug: print debug information\n"
    printf "noapt: don't add aptupgrade automatically. aptclean will still be run\n"
    
    printf "\nAvailable presets:\n\n"
    l="$(printf '%s\n' "${!presets[@]}"|wc -L)"
    k="$(printf '%s\n' "${!presets[@]}"|sort)"
    for p in $k
    do
        printf "%s:" "$p";printf %*s'' $((18 +2 - ${#p}));printf "%s\n" "${presets[$p]}" 
    done
    # for the documentation feature to work, add a commented line in the action script with the format # desc: <description>
    # this will be shown to the user:
    #!/usr/bin/bash
    # desc: installs k3d, a k3s management utility. Prereq: brew

    printf "\nAvailable actions:\n\n"

    l="$(printf '%s\n' "${!availableactions[@]}"|wc -L)"
    k="$(printf '%s\n' "${!availableactions[@]}"|sort)"
    for s in $k
    do
        printf "%s:" "$s";printf %*s'' $((18 +2 - ${#s}));printf '%s\n' "${availableactions[${s}]}" 
    done
    printf "\n"
    if [[ $sourced == "1" ]]; then return; else exit; fi
fi
# ask for confirmation to execute
while [[ -z $autoexec  ]] ; do
    read -p "Execute? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) if [[ $sourced == "1" ]]; then return; else exit; fi;;
        * ) echo "Please answer (y)es or (n)o.";;
    esac
done

printf '\nAuthorizing sudo: '
sudo ls >/dev/null
printf '\n'

declare -A outputs=() 
allstart=$(($(date +%s%N)/1000000))
mkdir -p logs; 
find logs ! -name 'currentaction.txt' -type f -exec rm -f {} +
for a in ${effectiveactions// / };do 
    echo -n ''>logs/$a.txt
    echo -n ''>logs/currentaction.txt
    start=$(($(date +%s%N)/1000000))
   cd $dirname
   printf "Executing '%s'" "$a";
    (. ./scripts/$a.sh 2>&1|tee logs/$a.txt >> logs/currentaction.txt) && o="OK"||o="FAIL" 
    end=$(($(date +%s%N)/1000000))
    ms=$(($end-$start))
    os=$(printf '%s: ' "$o";printf %*s'' $((8 - ${#ms}));printf "%s ms" "$ms")
    outputs["$a"]=$(printf '%s' "$os")
    printf %*s'' $((20 - ${#a}));printf "%s\n" "$os"
    . ~/.bashrc
done
allend=$(($(date +%s%N)/1000000))
allms=$(($allend-$allstart))
printf '\nAll done in %s ms \n\n' "$allms"
printf 'done\n' > logs/currentaction.txt

. ~/.bashrc
. ~/.profile