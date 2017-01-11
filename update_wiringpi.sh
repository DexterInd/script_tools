#!/bin/bash
source /home/pi/Dexter/lib/Dexter/script_tools/functions_library.sh

PIHOME=/home/pi
DEXTER=Dexter
LIB=lib


# Check if WiringPi Installed and has the latest version.  If it does, skip the step.
# Gets the version of wiringPi installed
version=`gpio -v`       

# Parses the version to get the number
set -- $version         

# Gets the third word parsed out of the first line of gpio -v returned.
# Should be 2.36
WIRINGVERSIONDEC=$3     

# Store to temp file
echo $WIRINGVERSIONDEC >> tmpversion    

# Remove decimals
VERSION=$(sed 's/\.//g' tmpversion)     

# Remove the temp file
delete_file tmpversion                           

feedback "wiringPi VERSION is $VERSION"
if [ $VERSION -eq '236' ]; then

    feedback "FOUND WiringPi Version 2.36 No installation needed."
else
    feedback "Did NOT find WiringPi Version 2.36"
    # Check if the Dexter directory exists.
    create_folder "$PIHOME/$DEXTER"
    create_folder "$PIHOME/$DEXTER/$LIB"

    # Change directories to Dexter/lib
    cd $PIHOME/$DEXTER/$LIB
    
    delete_folder wiringPi  
    # Install wiringPi
    git clone https://github.com/DexterInd/wiringPi/  # Clone directories to Dexter.
    cd wiringPi
    sudo chmod +x ./build
    sudo ./build
    feedback "wiringPi Installed"
fi
# End check if WiringPi installed
