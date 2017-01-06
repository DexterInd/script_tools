#! /bin/bash
#####################################################################
#####################################################################
#
# to install:
# curl https://raw.githubusercontent.com/DexterInd/script_tools/master/install_script_tools.sh | bash
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
    mkdir $DEXTER
fi
# go into $DEXTER
cd $DEXTER


# check if /home/pi/Dexter/lib exists, if not create it
if [ ! -d $LIB ] ; then
    mkdir $LIB
fi
cd $LIB

# check if /home/pi/Dexter/lib/Dexter exists, if not create it
if [ ! -d $DEXTER ] ; then
    mkdir $DEXTER
fi
cd $DEXTER


# check if /home/pi/Dexter/lib/script_tools exists
# if yes refresh the folder
# if not, clone the folder
if [ ! -d $SCRIPT ] ; then
    # clone the folder
    sudo git clone https://github.com/DexterInd/script_tools.git
else
    cd $SCRIPT
    sudo git pull
fi

popd