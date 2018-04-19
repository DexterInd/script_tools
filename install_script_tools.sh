#! /bin/bash
#####################################################################
#####################################################################
#
# to install:
# curl --silent https://raw.githubusercontent.com/DexterInd/script_tools/master/install_script_tools.sh | bash
#
#####################################################################
#####################################################################

command -v git >/dev/null 2>&1 || { echo "I require git but it's not installed. Aborting." >&2; exit 1; }
command -v python >/dev/null 2>&1 || { echo "Executable \"python\" couldn't be found. Aborting." >&2; exit 2; }

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
    --use-python3-command-too)
      usepython3exec=true
      ;;
    develop|feature/*|hotfix/*|fix/*|DexterOS*|v*)
      selectedbranch="$i"
      ;;
  esac
done

if $usepython3exec; then
  command -v python3 >/dev/null 2>&1 || { echo "Executable \"python3\" couldn't be found. Aborting." >&2; exit 3; }

DEXTER=Dexter
LIB=lib
SCRIPT=script_tools

pushd $HOME > /dev/null
result=${PWD##*/}

echo "Current directory is \"$result\""

# create folders recursively if they don't exist already
mkdir -p $HOME/$DEXTER/$LIB/$DEXTER

# it's simpler and more reliable (for now) to just delete the repo and clone a new one
# otherwise, we'd have to deal with all the intricacies of git
sudo rm -rf $SCRIPT
git clone --quiet --depth=1 -b $selectedbranch https://github.com/DexterInd/script_tools.git

# useful in case we need it
current_branch=$(git branch | grep \* | cut -d ' ' -f2-)

cd $HOME/$DEXTER/$LIB/$DEXTER/$SCRIPT

$updatedebs && sudo apt-get update
$installdebs && sudo apt-get install build-essential libi2c-dev i2c-tools python-dev libffi-dev -y
$systemwide && sudo python setup.py install --force \
            && $usepython3exec && sudo python3 setup.py install --force
$userlocal && python setup.py install --force --user \
            && $usepython3exec && python3 setup.py install --force --user
$envlocal && python setup.py install --force \
            && $usepython3exec && python3 setup.py install --force

popd > /dev/null
