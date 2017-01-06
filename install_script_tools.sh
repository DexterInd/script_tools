#! /bin/bash
#####################################################################
#####################################################################
#
# curl 
#
#####################################################################
#####################################################################

PIHOME=/home/pi
DEXTER=Dexter
LIB=lib
SCRIPT=script_tools

pushd $PIHOME
result=${PWD##*/} 
# check if ~/Dexter exists, if not create it
if [ ! -d $DEXTER ] ; then
	echo "creating $PIHOME/$DEXTER"
	mkdir $DEXTER
fi
# go into $DEXTER
cd $DEXTER
echo $PWD

# check if /home/pi/Dexter/lib exists, if not create it
if [ ! -d $LIB ] ; then
	echo "creating $PIHOME/$DEXTER/$LIB"
	mkdir $LIB
fi
cd $LIB
echo $PWD

# check if /home/pi/Dexter/lib/Dexter exists, if not create it
if [ ! -d $DEXTER ] ; then
	echo "creating $PIHOME/$DEXTER/$LIB/$Dexter"
	mkdir $DEXTER
fi
cd $DEXTER
echo $PWD

# check if /home/pi/Dexter/lib/script_tools exists
# if yes refresh the folder
# if not, clone the folder
if [ -d $SCRIPT ] ; then
	echo "Pulling"
	cd $SCRIPT
	echo $PWD
	echo "now in $PIHOME/$DEXTER/$LIB/$SCRIPT"
	sudo git pull
else
	# clone the folder
	echo "Cloning"
	sudo git clone https://github.com/DexterInd/script_tools.git
fi

popd