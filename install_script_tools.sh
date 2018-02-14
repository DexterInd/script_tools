#! /bin/bash
#####################################################################
#####################################################################
#
# to install:
# curl --silent https://raw.githubusercontent.com/DexterInd/script_tools/master/install_script_tools.sh | bash
#
#####################################################################
#####################################################################

PIHOME=/home/pi
DEXTER=Dexter
LIB=lib
SCRIPT=script_tools

pushd $PIHOME > /dev/null
result=${PWD##*/}
# check if ~/Dexter exists, if not create it
if [ ! -d $DEXTER ] ; then
    mkdir $DEXTER
fi
# go into $DEXTER
cd $PIHOME/$DEXTER


# check if /home/pi/Dexter/lib exists, if not create it
if [ ! -d $LIB ] ; then
    mkdir $LIB
fi
cd $PIHOME/$DEXTER/$LIB

# check if /home/pi/Dexter/lib/Dexter exists, if not create it
if [ ! -d $DEXTER ] ; then
    mkdir $DEXTER
fi
cd $PIHOME/$DEXTER/$LIB/$DEXTER


# check if /home/pi/Dexter/lib/script_tools exists
# if yes refresh the folder
# if not, clone the folder
if [ ! -d $SCRIPT ] ; then
    # clone the folder
    git clone --quiet https://github.com/DexterInd/script_tools.git
else
    cd $PIHOME/$DEXTER/$LIB/$DEXTER/$SCRIPT
    git pull --quiet
fi

cd $PIHOME/$DEXTER/$LIB/$DEXTER/$SCRIPT
sudo apt-get install build-essential libi2c-dev i2c-tools python-dev libffi-dev -y
python setup.py install
python3 setup.py install

popd > /dev/null
