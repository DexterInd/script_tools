#! /bin/bash
#####################################################################
#####################################################################
#
# to install:
# curl --silent https://raw.githubusercontent.com/DexterInd/script_tools/master/install_script_tools.sh | bash
#
#####################################################################
#####################################################################

# the following 3 options are mutually exclusive
systemwide=true
userlocal=false
envlocal=false

# the following 2 options can be used together
updatedebs=false
installdebs=false

# the following option tells which branch has to be used
selectedbranch="master" # set to master by default

# iterate through bash arguments
for i; do
  case "$i" in
    --user-local)
      userlocal=true
      systemwide=false
      ;;
    --env-local)
      envlocal=true
      systemwide=false
      ;;
    --system-wide)
      ;;
    --update-aptget)
      updatedebs=true
      ;;
    --just-install-deb-deps)
      installdebs=true
      ;;
    develop|feature/*|hotfix/*|fix/*|DexterOS*|v*)
      selectedbranch="$i"
      ;;
  esac
done

echo $systemwide
echo $userlocal
echo $envlocal
echo $selectedbranch

DEXTER=Dexter
LIB=lib
SCRIPT=script_tools

pushd $HOME > /dev/null
result=${PWD##*/}

echo $result

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
cd $HOME/$DEXTER/$LIB

# check if /home/pi/Dexter/lib/Dexter exists, if not create it
if [ ! -d $DEXTER ] ; then
    mkdir $DEXTER
fi
cd $HOME/$DEXTER/$LIB/$DEXTER


# check if /home/pi/Dexter/lib/script_tools exists
# if yes refresh the folder
# if not, clone the folder

# it's simpler and more reliable (for now) to just delete the repo and clone a new one
# otherwise, we'd have to deal with all the intricacies of git
sudo rm -rf $SCRIPT
git clone --quiet --depth=1 -b $selectedbranch https://github.com/DexterInd/script_tools.git

# useful in case we need it
current_branch=$(git branch | grep \* | cut -d ' ' -f2-)

cd $HOME/$DEXTER/$LIB/$DEXTER/$SCRIPT

[[ $updatedebs ]] && sudo apt-get update
[[ $installdebs ]] && sudo apt-get install build-essential libi2c-dev i2c-tools python-dev libffi-dev -y

[[ $systemwide ]] && sudo python setup.py install --force
[[ $userlocal ]] && python setup.py install --force --user
[[ $envlocal ]] && python setup.py install --force

popd > /dev/null
