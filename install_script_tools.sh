#! /bin/bash

PIHOME=/home/pi
DEXTER=Dexter
LIB=lib
DEXTER_PATH=$PIHOME/$DEXTER/$LIB/$DEXTER
DEXTER_SCRIPT=$DEXTER_PATH/script_tools
selectedbranch=master

################################################
######## Run a series of checks ################
################################################

# called way down bellow
check_if_run_with_pi() {
  ## if not running with the pi user then exit
  if [ $(id -ur) -ne $(id -ur pi) ]; then
    echo "script_tools installer script must be run with \"pi\" user. Exiting."
    exit 2
  fi
}

check_dependencies() {
  command -v git >/dev/null 2>&1 || { echo "This script requires \"git\" but it's not installed. Use \"--install-deb-deps\" option. Aborting." >&2; exit 1; }
}


################################################
########### Parse arguments ####################
################################################

parse_arguments() {
  # iterate through bash arguments
  for i; do
    case "$i" in
      develop|feature/*|hotfix/*|fix/*|DexterOS*|v*)
        selectedbranch="$i"
        ;;
    esac
  done
}

################################################
######## Cloning script_tools  #################
################################################

clone_scriptools(){
  # create folders recursively if they don't exist already
  # can't use <<functions_library.sh>> here because there's no
  # cloned script_tools yet at this part of the install script
  pushd $PIHOME > /dev/null
  sudo mkdir -p $DEXTER_PATH
  sudo chown pi:pi -R $PIHOME/$DEXTER
  popd > /dev/null

  # it's simpler and more reliable (for now) to just delete the repo and clone a new one
  # otherwise, we'd have to deal with all the intricacies of git
  sudo rm -rf $DEXTER_SCRIPT
  pushd $DEXTER_PATH > /dev/null
  git clone --quiet --depth=1 -b $selectedbranch https://github.com/DexterInd/script_tools.git
  cd $DEXTER_SCRIPT
  # useful in case we need it
  current_branch=$(git branch | grep \* | cut -d ' ' -f2-)
  popd > /dev/null
}

################################################
######## Aggregating all function calls ########
################################################

check_if_run_with_pi
parse_arguments
check_dependencies
clone_scriptools

exit 0
