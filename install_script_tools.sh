#! /bin/bash

PIHOME=/home/pi
DEXTER=Dexter
LIB=lib
DEXTER_PATH=$PIHOME/$DEXTER/$LIB/$DEXTER
DEXTER_SCRIPT=$DEXTER_PATH/script_tools

# selectedbranch variable is defined in parse_arguments function

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
  command -v git >/dev/null 2>&1 || { echo "This script requires \"git\" but it's not installed. Aborting." >&2; exit 1; }
}


################################################
########### Parse arguments ####################
################################################

parse_arguments() {

  selectedbranch=master
  rpidetector=false
  usepython3exec=false
  userlocal=false
  systemwide=false
  envlocal=false

  # iterate through bash arguments
  for i; do
    case "$i" in
      develop|feature/*|hotfix/*|fix/*|DexterOS*|v*)
        selectedbranch="$i"
        ;;
      --install-rpi-detector)
        rpidetector=true
        ;;
      --use-python3-exe-too)
        usepython3exec=true
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
######## Install/Remove Python Packages ########
################################################

# called by <<install_python_pkgs_and_dependencies>>
install_python_packages() {
  [[ $systemwide = "true" ]] && sudo python setup.py install \
              && [[ $usepython3exec = "true" ]] && sudo python3 setup.py install
  [[ $userlocal = "true" ]] && python setup.py install --user \
              && [[ $usepython3exec = "true" ]] && python3 setup.py install --user
  [[ $envlocal = "true" ]] && python setup.py install \
              && [[ $usepython3exec = "true" ]] && python3 setup.py install
}

# called by <<install_python_pkgs_and_dependencies>>
remove_python_packages() {
  # the 1st and only argument
  # takes the name of the package that needs to removed
  rm -f $PIHOME/.pypaths

  # get absolute path to python package
  # saves output to file because we want to have the syntax highlight working
  # does this for both root and the current user because packages can be either system-wide or local
  # later on the strings used with the python command can be put in just one string that gets used repeatedly
  python -c "import pkgutil; import os; \
              eggs_loader = pkgutil.find_loader('$1'); found = eggs_loader is not None; \
              output = os.path.dirname(os.path.realpath(eggs_loader.get_filename('$1'))) if found else ''; print(output);" >> $PIHOME/.pypaths
  sudo python -c "import pkgutil; import os; \
              eggs_loader = pkgutil.find_loader('$1'); found = eggs_loader is not None; \
              output = os.path.dirname(os.path.realpath(eggs_loader.get_filename('$1'))) if found else ''; print(output);" >> $PIHOME/.pypaths
  if [[ $usepython3exec = "true" ]]; then
    python3 -c "import pkgutil; import os; \
                eggs_loader = pkgutil.find_loader('$1'); found = eggs_loader is not None; \
                output = os.path.dirname(os.path.realpath(eggs_loader.get_filename('$1'))) if found else ''; print(output);" >> $PIHOME/.pypaths
    sudo python3 -c "import pkgutil; import os; \
                eggs_loader = pkgutil.find_loader('$1'); found = eggs_loader is not None; \
                output = os.path.dirname(os.path.realpath(eggs_loader.get_filename('$1'))) if found else ''; print(output);" >> $PIHOME/.pypaths
  fi

  # removing eggs for $1 python package
  # ideally, easy-install.pth needs to be adjusted too
  # but pip seems to know how to handle missing packages, which is okay
  while read path;
  do
    if [ ! -z "${path}" -a "${path}" != " " ]; then
      echo "Removing ${path} egg"
      sudo rm -f "${path}"
    fi
  done < $PIHOME/.pypaths
}

# called way down bellow
install_remove_python_packages() {
  if [[ $installpythonpkg = "true" ]]; then
    echo "Removing \"$REPO_PACKAGE\" to make space for the new one"
    remove_python_packages "$REPO_PACKAGE"

    echo "Installing python package for RFR_Tools "
    # installing the package itself
    pushd $DEXTER_SCRIPT > /dev/null
    install_python_packages
    popd > /dev/null
  fi
}

################################################
######## Aggregating all function calls ########
################################################

check_if_run_with_pi
parse_arguments "$@"
check_dependencies
clone_scriptools
install_remove_python_packages

exit 0
