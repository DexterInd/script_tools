#! /bin/bash

################################################
######## Parsing Command Line Arguments ########
################################################

OS_CODENAME=$(lsb_release --codename --short)

# the following option is required should the python package be installed
# by default, the python package are not installed
installpythonpkg=false

# the following 3 options are mutually exclusive
systemwide=true
userlocal=false
envlocal=false
usepython3exec=false

# the following 2 options can be used together
updatedebs=false
installdebs=false

# the following option tells which branch has to be used
selectedbranch="master" # set to master by default

# iterate through bash arguments
for i; do
  case "$i" in
    --install-python-package)
      installpythonpkg=true
      ;;
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
    --install-deb-deps)
      installdebs=true
      ;;
    --use-python3-exe-too)
      usepython3exec=true
      ;;
    develop|feature/*|hotfix/*|fix/*|DexterOS*|v*)
      selectedbranch="$i"
      ;;
  esac
done


# exit if git is not installed
if [[ $installdebs = "false" ]]; then
  command -v git >/dev/null 2>&1 || { echo "I require git but it's not installed. Use \"--install-deb-deps\" option. Aborting." >&2; exit 1; }
fi

# exit if python/python3 are not installed in the current environment
if [[ $installpythonpkg = "true" ]]; then
  command -v python >/dev/null 2>&1 || { echo "Executable \"python\" couldn't be found. Aborting." >&2; exit 2; }
  if [[ $usepython3exec = "true" ]]; then
    command -v python3 >/dev/null 2>&1 || { echo "Executable \"python3\" couldn't be found. Aborting." >&2; exit 3; }
  fi
fi

DEXTER=Dexter
LIB=lib
SCRIPT=script_tools

pushd $HOME > /dev/null
result=${PWD##*/}

echo "Updating script_tools for $selectedbranch branch with the following options:"
echo "--install-python-package=$installpythonpkg"
echo "--system-wide=$systemwide"
echo "--user-local=$userlocal"
echo "--env-local=$envlocal"
echo "--use-python3-exe-too=$usepython3exec"
echo "--update-aptget=$updatedebs"
echo "--install-deb-deps=$installdebs"

# create folders recursively if they don't exist already
sudo mkdir -p $HOME/$DEXTER/$LIB/$DEXTER
sudo chown pi:pi -R $HOME/$DEXTER
cd $HOME/$DEXTER/$LIB/$DEXTER

################################################
######## Installing Dependencies  ##############
################################################

if [[ $updatedebs = "true" ]]; then
  # bring in nodejs repo

  # to confirm nodejs is available for the given distribution
  curl -sLf -o /dev/null "https://deb.nodesource.com/node_9.x/dists/$OS_CODENAME/Release"
  ret_val=$?
  if [[ $ret_val -e 0 ]]; then
    # add gpg key for nodejs
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
    # add nodejs to apt-get source list
    sudo sh -c "echo 'deb https://deb.nodesource.com/node_9.x $OS_CODENAME main' > /etc/apt/sources.list.d/nodesource.list"
    sudo sh -c "echo 'deb-src https://deb.nodesource.com/node_9.x $OS_CODENAME main' >> /etc/apt/sources.list.d/nodesource.list"
  else
    echo "Couldn't add Nodejs repo because it's not available for this distribution"
  fi

  sudo apt-get update
fi
[[ $installdebs = "true" ]] && sudo apt-get install git build-essential libi2c-dev i2c-tools python-dev python3-dev python-setuptools python3-setuptools libffi-dev -y

################################################
######## Cloning script_tools  #################
################################################

# it's simpler and more reliable (for now) to just delete the repo and clone a new one
# otherwise, we'd have to deal with all the intricacies of git
sudo rm -rf $SCRIPT
git clone --quiet --depth=1 -b $selectedbranch https://github.com/DexterInd/script_tools.git
cd $SCRIPT

################################################
######## Installing Packages  ##################
################################################

# useful in case we need it
current_branch=$(git branch | grep \* | cut -d ' ' -f2-)

if [[ $installpythonpkg = "true" ]]; then
  [[ $systemwide = "true" ]] && sudo python setup.py install --force \
              && [[ $usepython3exec = "true" ]] && sudo python3 setup.py install --force
  [[ $userlocal = "true" ]] && python setup.py install --force --user \
              && [[ $usepython3exec = "true" ]] && python3 setup.py install --force --user
  [[ $envlocal = "true" ]] && python setup.py install --force \
              && [[ $usepython3exec = "true" ]] && python3 setup.py install --force
fi

popd > /dev/null

exit 0
