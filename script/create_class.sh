#!/bin/bash


#--------------------------------------------------
#  global vars
#--------------------------------------------------

bIsHpp=f
bHasParent=f
bHasNamespace=f
bExplicitDefault=f

sClassname=""
sParentClassname=""
sNamespace=""


#--------------------------------------------------
#  function definitions
#--------------------------------------------------


fnReadClassName()
{
	local sInBuffer=""
	
	while [ -z $sInBuffer ];
	do
		echo "class name:"
		read sInBuffer
	done
	
	sClassname=$sInBuffer
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
			bIsHpp="t"
		elif [ $sInBuffer == "n" ] || [ $sInBuffer == "N" ] ;
		then
			bValid=1
			bIsHpp="f"
		else
			bValid=""
		fi
	done
}


fnReadParentClass()
{
	local sInBuffer="n"
	local bValid=""
	
	while [ -z $bValid ];
	do
		echo "Inherits from a class (y/N)?"
		read sInBuffer
		if [ [ sInBuffer == "y" ] || [ sInBuffer == "Y" ] ]
		then
			bValid=1
			bHasParent=t
		elif [ [ sInBuffer == "n" ] || [ sInBuffer == "N" ] ]
		then
			bValid=1
			bHasParent=f
			sParentClassname="n/a"
		else
			bValid=""
		fi
	done
	
	inBuffer=""
	if [ bHasParent == t ]
	then
		while [[ -n inBuffer ]]
		do
			echo "Parent class name:"
			read inBuffer
		done
		
		sParentClassname=$inBuffer
	fi
}


fnReadNamespace()
{
	local sInBuffer=""
	local bValid=""
	
	while [[ -n bValid ]]
	do
		echo "Add under a namespace? (y/N)"
		read sInBuffer
		if [ [ sInBuffer == "y" ] || [ sInBuffer == "Y" ] ]
		then
			bValid=1
			bHasNamespace=t
		elif [ [ sInBuffer == "n" ] || [ sInBuffer == "N" ] ]
		then
			bValid=1
			bHasNamespace=f
			sNamespace="n/a"
		else
			bValid=""
		fi
	done
	
	if [ bHasNamespace == t ]
	then
		while [[ -n inBuffer ]]
		do
			echo "Namespace name:"
			read inBuffer
		done
		
		sNamespace=$inBuffer
	fi	
}


fnReadExplicitFunctions(){
	while [[ -n bValid ]]
	do
		echo "Make functions explicit default? (y/N)"
		read sInBuffer
		if [ [ sInBuffer == "y" ] || [ sInBuffer == "Y" ] ]
		then
			bValid=1
			inExplicitDef=t
		elif [ [ sInBuffer == "n" ] || [ sInBuffer == "N" ] ]
		then
			bValid=1
			inExplicitDef=f
		else
			bValid=""
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


fnReadClassName
fnReadHeaderExtension
fnReadParentClass
fnReadNamespace
fnReadExplicitFunctions


echo Class name:                    $sClassname
echo Parent class name:             $sParentClassname
echo Namespace name:                $sNamespace
echo Header extension:              $bIsHpp
echo Explicit default functions:    $bExplicitDefault


#TODO: check input
#read

#--------------------------------------------------
#  create file
#--------------------------------------------------

sFileExtension=""

#if[[ -n -z VarName ]] 
#fi
if [ bIsHpp==true ] ;
then
	sFileExtension=".h"
else
	sFileExtension=".hpp"
fi





popd #from $scriptdir
