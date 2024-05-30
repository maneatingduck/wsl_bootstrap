#!/usr/bin/env sh
# . ./bootstrap_selected.sh "brew oc kubectl krew k9s"
inp=$1
availableactionsstring="noaptupdate nonukesnap brew winconfig terraform k9s az oc kubectl krew docker tsh k3d jq"
if [[ $inp == "all" ]];then
    inp=$(echo $availableactionsstring |sed 's/noaptupdate\|nonukesnap//g' )
    # echo "all -> $inp"
fi
if [[ $inp == "openshift" ]];then
    inp="brew winconfig terraform k9s az oc kubectl krew docker tsh k3d jq"
    # echo "all -> $inp"
fi

inp=$(echo $inp |sed 's/ +/ /g' )
printf "Running the following:\n$inp\nenter to accept"
read
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )">/dev/null 2>&1
echo $SCRIPTPATH
IFS=" " read -ra availableactions <<< $availableactionsstring
IFS="," read -ra rawdeps <<< "brew oc,brew k9s"
if [[ ${inputactions[@]} =~ "nonukesnap" ]];then
    echo nonukesnap input
fi
if [[ ! ${inputactions[@]} =~ "nonukesnap" ]];then
    echo yesnukesnap
    . ./nukesnap.sh
fi

if [[ ! ${inputactions[@]} =~ "noaptupdate" ]];then
    time sudo apt-get update
    time sudo apt-get upgrade -y
fi
IFS=" " read -ra inputactions <<< $inp

for action in "${inputactions[@]}"
do
    echo "action $action"
    # read
    cd $SCRIPTPATH
    if [ $action == "brew"      ];then echo "run script for $action"; . scripts/brew.sh          ;fi
    if [ $action == "az"        ];then echo "run script for $action"; . scripts/az.sh            ;fi
    if [ $action == "oc"        ];then echo "run script for $action"; . scripts/oc.sh            ;fi
    if [ $action == "kubectl"   ];then echo "run script for $action"; . scripts/kubectl.sh       ;fi
    if [ $action == "krew"      ];then echo "run script for $action"; . scripts/krew.sh          ;fi
    if [ $action == "k9s"       ];then echo "run script for $action"; . scripts/k9s.sh           ;fi
    if [ $action == "k3d"       ];then echo "run script for $action"; . scripts/k3d.sh           ;fi
    if [ $action == "tsh"       ];then echo "run script for $action"; . scripts/tsh.sh           ;fi
    if [ $action == "jq"        ];then echo "run script for $action"; . scripts/jq.sh           ;fi
    if [ $action == "docker"    ];then echo "run script for $action"; . scripts/docker.sh        ;fi
    if [ $action == "terraform" ];then echo "run script for $action"; . scripts/terraform.sh     ;fi
    if [ $action == "winconfig" ];then echo "run script for $action"; . scripts/winconfig.sh     ;fi
done
cd $SCRIPTPATH

# popd
# if [ ${#inputactions[@]} -eq 0 ]; then
#     ERROR+=("no input selections made")
# fi;

# for dep in "${rawdeps[@]}"
# do 
#     echo $dep 
#     IFS=" " read -ra idep <<< dep
#     echo "dependant: ${idep[0]}, req: ${idep[1]}"
#     ideppresent=""
#     for inputaction in "${inputactions[@]}"
#     do 
#         if [[ $inputaction == $idep[1]  ]];then
#             echo bah
#         fi
#     done

# done



# #check that all input vars are available as actions
# echo "check valid input"
# if [ -z "${ERROR}" ]; then 
#     for a in "${inputactions[@]}"
#     do
#         echo $inputactions[$i]
#     done
# fi


# # echo ${#inputactions[@]}
# # echo ${inputactions[*]}
# if [ ${#ERROR[@]} > 0 ];then
#     echo ${ERROR[*]}
#     exit
# fi


# # for i in "${inputactions[@]}"
# # do
# #    echo "$i"
# #    # or do whatever with individual element of the array
# # done