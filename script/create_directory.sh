#!/bin/bash

#TODO: checkthis
sArrPaths=()

#fnReverseArray
#  param1: array to reverse
#  param2: output array
fnReverseArray()
{
	#check parameter count
	if [[ "$#" != 2 ]];
	then
		echo "error: invalid argument count (should be 2)"
		echo "  param1: array to reverse"
		echo "  param2: output array"
		return 1
	fi

	declare -n arr="$1" rev="$2"
    for i in "${arr[@]}"
    do
        rev=("$i" "${rev[@]}")
    done
}


#fnCreateSubdirectory
#  param1: root directory path
#  param2: path inside root directory
fnCreateSubdirectory ()
{
	#check parameter count
	if [[ "$#" < 2 ]];
	then
		echo "error: too few arguments"
		return 1
	elif [[ "$#" > 2 ]];
	then
		echo "error: too many arguments"
		return 1
	fi
	
	#define locals
	local sPathRoot=$1
	local sPathRel=$2
	local sCurrent=$sPathRel
	local sArrPaths=()
	local bDone=0
	local iCount=0
	
	#find the deepest folder that already exists
	#  and collect each, that doesn't
	bDone=0
	while [[ $bDone == 0 ]];
	do
		#if path doesn't exist
		if [[ 0 != $(test -e $sCurrent) ]] && [[ $sCurrent != "" ]] && [[ $sCurrent != '.' ]];
		then
			#sArrPaths+=${sCurrent}
			sArrPaths+=(${sCurrent})
			echo $sCurrent
			echo $iCount
			echo ${sArrPaths[*]}
			echo ${sArrPaths[@]}
			sCurrent=$(dirname -- $sCurrent)
			iCount=$((iCount + 1))
		else
			bDone=1
		fi
	done
	
	sArrPathsRev=()
	
	#create missing folders
	fnReverseArray sArrPaths sArrPathsRev
	
	echo B:${sArrPathsRev[@]}

	mkdir ${sArrPathsRev[@]}
	
	return 0
}
