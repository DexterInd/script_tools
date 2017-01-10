#!/usr/bin/env bash

# Create AVRDUDE folder. Create it if it does not exist
create_avrdude_folder(){
    AVRDUDE_DIR='/home/pi/Dexter/lib/AVRDUDE'
    if [ -d "$AVRDUDE_DIR" ]; then
        echo $AVRDUDE_DIR" Found!"
    else 
        DIRECTORY='/home/pi/Dexter'
        if [ -d "$DIRECTORY" ]; then
            # Will enter here if $DIRECTORY exists, even if it contains spaces
            echo $DIRECTORY" Directory Found !"
        else
            echo "creating "$DIRECTORY
            mkdir $DIRECTORY
        fi

        DIRECTORY='/home/pi/Dexter/lib'
        if [ -d "$DIRECTORY" ]; then
            # Will enter here if $DIRECTORY exists, even if it contains spaces
            echo $DIRECTORY" Directory Found!"
        else
            echo "creating "$DIRECTORY
            mkdir $DIRECTORY
        fi
        
        pushd $DIRECTORY
        git clone https://github.com/DexterInd/AVRDUDE.git
        popd
    fi
}
# Install Avrdude 5.1 from Dexter repos
install_avrdude(){
    #Updating AVRDUDE
    FILENAME=tmpfile.txt
    AVRDUDE_VER=5.10
    avrdude -v &> $FILENAME
    
    #Only install avrdude 5.1 if it does not exist
    if grep -q $AVRDUDE_VER $FILENAME 
    then
        echo "avrdude" $AVRDUDE_VER "Found"
    else
        echo "avrdude" $AVRDUDE_VER "Not Found,Installing avrdude now"
        create_avrdude_folder
        
        ##########################################
        #Installing AVRDUDE
        ##########################################
        pushd /home/pi/Dexter/lib/AVRDUDE/avrdude
        
        # Install the avrdude deb package
        # No need to wget since files should be there in the avrdude folder
        # wget https://github.com/DexterInd/AVRDUDE/raw/master/avrdude/avrdude_5.10-4_armhf.deb
        sudo dpkg -i avrdude_5.10-4_armhf.deb 
        sudo chmod 4755 /usr/bin/avrdude
        
        # Setup config files 
        # wget http://project-downloads.drogon.net/gertboard/setup.sh
        chmod +x setup.sh
        sudo ./setup.sh  
        
        # pushd /etc/minicom
        # sudo wget http://project-downloads.drogon.net/gertboard/minirc.ama0
        # sudo sed -i '/Exec=arduino/c\Exec=sudo arduino' /usr/share/applications/arduino.desktop
        echo " "
        popd
    fi
    rm $FILENAME   
}
