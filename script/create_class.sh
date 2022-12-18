#!/bin/bash

#--------------------------------------------------
#  global vars
#--------------------------------------------------

bIsHpp="false"
bHasParent="false"
bHasNamespace="false"
bExplicitDefault="false"

sHeaderExt=".h"
sClassname="n/a"
sFileNameH="n/a"
sFileNameS="n/a"

sParentClassname="n/a"
sNamespace="n/a"

#TODO: read
sFilePathH=""
sFilePathS=""


#--------------------------------------------------
#  function definitions
#--------------------------------------------------


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
	local sArrPathsRev=()
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
			sArrPaths+=(${sCurrent})
			sCurrent=$(dirname $sCurrent)
			iCount=$((iCount + 1))
		else
			bDone=1
		fi
	done

	#reverse the array of paths to get correct order
	fnReverseArray sArrPaths sArrPathsRev

	#create missing folders
	mkdir ${sArrPathsRev[@]}

	return 0
}


fnReadClassName()#CFG_START
{
	local sInBuffer=""

	while [ -z $sInBuffer ];
	do
		echo -n "class name: "
		read sInBuffer
	done

	sClassname=${sInBuffer}
	sFileNameH=${sInBuffer}
	sFileNameS=${sInBuffer}.cpp
	#sFileNameH=$(echo $ClassName | tr [:upper:] [:lower:])
	#sFileNameS=$(echo $ClassName | tr [:upper:] [:lower:])
}


fnReadHeaderExtension()
{
	local sInBuffer=""
	local bValid=""

	while [ -z $bValid ];
	do
		echo -n "Header is .h and NOT .hpp? (Y/n): "
		read sInBuffer

		if [ -z $sInBuffer ];
		then
			bValid=1
		elif [ $sInBuffer == "y" ] || [ $sInBuffer == "Y" ];
		then
			bValid=1
			bIsHpp="true"
			sHeaderExt=".h"
		elif [ $sInBuffer == "n" ] || [ $sInBuffer == "N" ] ;
		then
			bValid=1
			bIsHpp="false"
			sHeaderExt=".hpp"
		else
			bValid=""
			echo "invalid parameter!"
		fi
	done
	sFileNameH=${sFileNameH}${sHeaderExt}
	sFilePathH=${sFileNameH}
	sFilePathS=${sFileNameS}
}


fnReadFilePath()
{
	#check parameter count
	if [[ "$#" != 1 ]];
	then
		echo "error: invalid argument count"
		echo "  param1: path to project folder"
		return 1
	fi
	
	#local vars
	local sProjectPath=$1
	local sInBuffer=""
	local bValid="" # "" or 1
	local bFilesExist=0
	local sFilePathH=""
	local sFilePathS=""

	while [ -z $bValid ];
	do
		bValid=""
		bFilesExist=0
		sInBuffer=""
		echo -n "Path inside 'include/' and 'src/': "
		read sInBuffer

		#TODO: check this, whether it defaults to root, etc.
		#		it shouldn't do root, and give error instead
		if [[ -n $sInBuffer ]];
		then
			sInBuffer=$sInBuffer"/"
		fi

		sFilePathH=${sInBuffer}${sFileNameH}
		sFilePathS=${sInBuffer}${sFileNameS}
		sAbsPathH=${sProjectPath}'/include/'${sFilePathH}
		sAbsPathS=${sProjectPath}'/src/'${sFilePathS}
		
		#check whether files exist
		if [ -a $sAbsPathH ];
		then
			echo "ERROR: " $sAbsPathH " already exists!"
			bFilesExist=1
			bValid=""
		fi

		if [ -a $sAbsPathS ];
		then
			echo "ERROR: " $sAbsPathS " already exists!"
			bFilesExist=1
			bValid=""
		fi


		if [[ 0 == $bFilesExist ]];
		then
			echo Header path: "include/"${sFilePathH}
			echo Source path: "src/"${sFilePathS}
			echo -n "OK? (Y/n) "

			sFilePathH="${ProjectDir}/include/"${sInBuffer}${sFileNameH}
			sFilePathS="${ProjectDir}/src/"${sInBuffer}${sFileNameS}


			sInBuffer=""
			read sInBuffer

			if [ -z $sInBuffer ] || [ $sInBuffer == "y" ] || [ $sInBuffer == "Y" ];
			then
				bValid=1
			else
				if [ $sInBuffer == "n" ] || [ $sInBuffer == "N" ] ;
				then
					bValid=""
				fi
				echo "invalid parameter!"
			fi
		fi
	done
}



fnReadParentClass()
{
	local sInBuffer=""
	local bValid=""

	while [ -z $bValid ];
	do
		echo "Inherits from a class? (y/N) "
		read sInBuffer

		if [ -z $sInBuffer ];
		then
			bValid=1
		elif [ $sInBuffer == "y" ] || [ $sInBuffer == "Y" ];
		then
			bValid=1
			bHasParent="true"
		elif [ $sInBuffer == "n" ] || [ $sInBuffer == "N" ];
		then
			bValid=1
			bHasParent="false"
			sParentClassname="n/a"
		else
			bValid=""
			echo "invalid parameter!"
		fi
	done

	sInBuffer=""
	if [ $bHasParent == "true" ]
	then
		while [ -z $sInBuffer ]
		do
			echo "Parent class name:"
			read sInBuffer
		done

		sParentClassname=$sInBuffer
	fi
}


fnReadNamespace()
{
	local sInBuffer=""
	local bValid=""

	while [[ -z $bValid ]]
	do
		echo -n "Add under a namespace? (y/N) "
		read sInBuffer

		if [ -z $sInBuffer ];
		then
			bValid=1
		elif [ $sInBuffer == "y" ] || [ $sInBuffer == "Y" ];
		then
			bValid=1
			bHasNamespace="true"
		elif [ $sInBuffer == "n" ] || [ $sInBuffer == "N" ];
		then
			bValid=1
			bHasNamespace="false"
			sNamespace="n/a"
		else
			bValid=""
			echo "invalid parameter!"
		fi
	done

	sInBuffer=""
	if [ $bHasNamespace == "true" ]
	then
		while [[ -z $sInBuffer ]]
		do
			echo "Namespace name:"
			read sInBuffer
		done

		sNamespace=$sInBuffer
	fi	
}


fnReadExplicitFunctions()
{
	local sInBuffer=""
	local bValid=""

	while [[ -z $bValid ]]
	do
		echo -n "Make functions explicit default? (y/N) "
		read sInBuffer
		if [ -z $sInBuffer ];
		then
			bValid=1
		elif [ $sInBuffer == "y" ] || [ $sInBuffer == "Y" ];
		then
			bValid=1
			bExplicitDefault="true"
		elif [ $sInBuffer == "n" ] || [ $sInBuffer == "N" ];
		then
			bValid=1
			bExplicitDefault="false"
		else
			bValid=""
			echo "invalid parameter!"
		fi
	done

}


#--------------------------------------------------
#  Script Start
#--------------------------------------------------

#find out script directory
pushd $(dirname "${BASH_SOURCE[0]}") > /dev/null
scriptdir=$(pwd)
popd > /dev/null

#at this point, the path is <projectpath>/script/..
#fix it to <projectpath>
ProjectDir=$(dirname $scriptdir)


#prompt the user for the class properties
fnReadClassName
fnReadHeaderExtension
fnReadFilePath $ProjectDir
#fnReadParentClass
#fnReadNamespace
fnReadExplicitFunctions


#print an overview of the answers
echo "--------------------------------------------------"
if [ $bHasNamespace == "true" ];
then
	echo "Namespace name:             " $sNamespace
fi

echo "Class name:                 " $sClassname
echo "Header file name:           " $sFileNameH
echo "Source file name:           " $sFileNameS
echo "Header file relative path:  " $sFilePathH
echo "Source file relative path:  " $sFilePathS

if [ $bHasParent == "true" ];
then
	echo "Parent class name:          " $sParentClassname
fi

if [ $bExplicitDefault == "true" ];
then
	echo "Explicit default functions: " $bExplicitDefault
fi
echo "--------------------------------------------------"

#
#TODO:
#	check existing files!
sProjectRoot=""
sFPathH=${sProjectRoot}"/"${sFilePathH}
sFPathS=${sProjectRoot}"/"${sFilePathS}

#check for conflicts with existing files
bAbortCopy="false"

if [[ -e $sFPathH ]];
then
	echo "ERROR: file '$sFPathH' already exists!"
	bAbortCopy="true"
fi

if [[ -e $sFPathS ]];
then
	echo "ERROR: file '$sFPathS' already exists!"
	bAbortCopy="true"
fi

if [ $bAbortCopy=="false" ];
then
	FData=$(cat ./data/newclass.h)

	#replace class name

	#remove/rename namespace ?




fi

#TODO: check input
#read

#--------------------------------------------------
#  create file
#--------------------------------------------------

#TODO: get scriptfolder
soParentInclude='#include "'$sParentClassname'.h"'
soNamespaceOpen="namespace "$sNamespace"{"
soNamespaceClose="} // end of namespace '"$sNamespace"'"
soClassName=$sClassname
soParentClassInherit=": public "$sParentClassname
soDefDefault=" = default"


if [[ bHasParent=="false" ]];
then
	soParentInclude=""
	soParentClassInherit=""
fi


if [[ bHasNamespace=="false" ]];
then
	soNamespace=""
	soNamespaceOpen=""
	soNamespaceClose=""
else
	#TODO: set up 'mkdir' for namespace paths
	echo
fi


if [[ bExplicitDefault=="false" ]];
then
	soDefDefault=""
fi


cat $scriptdir/data/newclass.h | sed 's/__parentInclude__/$soParentInclude/g' | sed 's/__namespaceOpen__/$soNamespaceOpen/g' | sed 's/__namespaceClose__/$soNamespaceClose/g' | sed 's/__className__/$soClassName/g' | sed 's/__parentClassInherit__/$soParentClassInherit/g' | sed 's/__defDefault__/$soDefDefault/g' > $sFilePathH

