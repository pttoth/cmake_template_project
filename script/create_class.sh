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


fnReadClassName()#CFG_START
{
	local sInBuffer=""

	while [ -z $sInBuffer ];
	do
		echo "class name:"
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
		echo "Header is .h and NOT .hpp? (Y/n) ('n', if .hpp)"
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
	sFilePathH="include/"${sFileNameH}
	sFilePathS="src/"${sFileNameS}
}


fnReadFilePath()
{
	local sInBuffer=""
	local bValid=""

	while [ -z $bValid ];
	do
		sInBuffer=""
		echo "Path inside 'include/' and 'src/' :"
		read sInBuffer

		if [[ -n $sInBuffer ]];
		then
			sInBuffer=$sInBuffer"/"
		fi

		sFilePathH="include/"${sInBuffer}${sFileNameH}
		sFilePathS="src/"${sInBuffer}${sFileNameS}

		echo Header path: $sFilePathH
		echo Source path: $sFilePathS
		echo "OK? (Y/n)"

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
	done
}



fnReadParentClass()
{
	local sInBuffer=""
	local bValid=""

	while [ -z $bValid ];
	do
		echo "Inherits from a class (y/N)?"
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
		echo "Add under a namespace? (y/N)"
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
		echo "Make functions explicit default? (y/N)"
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
#  read + confirmation
#--------------------------------------------------

#find out script directory
pushd $(dirname "${BASH_SOURCE[0]}") > /dev/null
scriptdir=$(pwd)
popd > /dev/null

#move to project root directory
#pushd $scriptdir
#popd #from $scriptdir



fnReadClassName
fnReadHeaderExtension
fnReadFilePath
fnReadParentClass
fnReadNamespace
fnReadExplicitFunctions


echo "--------------------------------------------------"
if [ $bHasNamespace == "true" ];
then
	echo "Namespace name:             " $sNamespace
fi

echo "Class name:                 " $sClassname
echo "Header file path:           " $sFilePathH
echo "Source file path:           " $sFilePathS

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


#TODO: check input
#read

#--------------------------------------------------
#  create file
#--------------------------------------------------

#if[[ -n -z VarName ]] 
#fi
if [ bIsHpp=="true" ] ;
then
	sFileExtension=".h"
else
	sFileExtension=".hpp"
fi






