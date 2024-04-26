# winuser=$(cmd.exe /c "echo %USERNAME%")
# if [ $winuser == "" ]; then 
#   echo "windows username not detected, please enter it"&&read winuser
# else
#     echo $winuser
# fi

IFS=" " read -ra availableactions <<< "k9s brew oc"
IFS="," read -ra rawdeps <<< "oc brew,k9s brew"
echo "rawdeps: ${rawdeps[*]}"
IFS=" " read -ra inputactions <<< $1
echo "check valid input"
    for a in "${inputactions[@]}"
    do
        echo $inputactions[$i]
    done

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