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

pushd $PIHOME

# check if ~/Dexter exists, if not create it
if [ ! -d $DEXTER ] ; then
	echo "creating $PIHOME/$DEXTER"
	mkdir $DEXTER
fi
# go into $DEXTER
cd $DEXTER

# check if /home/pi/Dexter/lib exists, if not create it
if [ ! -d $LIB ] ; then
	echo "creating $PIHOME/$DEXTER/$LIB"
	mkdir $LIB
fi

# check if /home/pi/Dexter/lib/Dexter exists
# if yes refresh the folder
# if not, clone the folder
if [ -d $DEXTER ] ; then
	echo "Pulling"
	cd $DEXTER
	sudo git pull
else
	# clone the folder
	echo "Cloning"
	sudo git clone https://github.com/DexterInd/script_tools.git
fi

popd