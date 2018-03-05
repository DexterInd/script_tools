##############################################################
##############################################################
# 
# A SERIES OF HELPER FUNCTIONS TO HELP OUT IN 
# HANDLING SCRIPTS THAT ARE GROWING IN COMPLEXITY
#
##############################################################
##############################################################

quiet_mode() {
  # verify quiet mode
  # returns 0 if quiet mode is enabled
  # returns 1 otherwise
  if [ -f /home/pi/quiet_mode ]
  then
    return 0
  else
    return 1
  fi
}

set_quiet_mode(){
  touch /home/pi/quiet_mode
}

unset_quiet_mode(){
  delete_file /home/pi/quiet_mode
}


feedback() {
  # first parameter is text to be displayed
  # this sets the text color to a yellow color for visibility
  # the last tput resets colors to default
  # one could also set background color with setb instead of setaf
  #http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
  echo -e "$(tput setaf 3)$1$(tput sgr0)"
}

# Function checks out branch if BRANCH is defined.
change_branch() {
  # first and only parameter is the branch to checkout

  # -z tests for zero length. 
    if [ -z ${1+x} ]; then 
        echo "Working from main branch."; 
    else 
        echo "Working from $1 branch";
        # sudo git checkout -b $BRANCH
        # the -b creates a branch if it doesn't exist
        # this leads to a fatal error msg being displayed to the user
        # is there any case where we can to create the branch here???
        # https://github.com/tldr-pages/tldr/blob/master/pages/common/git-checkout.md
        sudo git checkout $1
    fi
}

###########################################################################
#
# USB drive stuff
#
###########################################################################

# get_usb_mount_point - get the USB drive directory (the mount point), if present
#
# writes the path name to stdout
#
# Returns: 0 on success or 1 on failure


get_usb_mount_point() {
  # devmon mounts usb drive to /media/

  active_drives=$(ls /dev/disk/by-partuuid/ | tr '\n' ' ' 2>/dev/null)
  real_media_points=""
  for active_drive in $active_drives
  do
    output=$(findmnt -rn -S PARTUUID="$active_drive" -o TARGET)
    errcode=$?
    if [[ $errcode == 0 ]]; then
      real_media_points="$real_media_points$output "
    fi
  done
  real_media_points=$(echo -e "$real_media_points")

  OIFS="$IFS"
  IFS=$'\n'
  find /media -maxdepth 1 -mindepth 1 | while read media_point
  do
    # spaces in the compared strings must stay
    if [[ "$real_media_points " = *"$media_point "* ]]; then
      echo "$media_point"
      return 0
    fi
  done
  IFS="$OIFS"

  return 1
}

# get_usb_symlink_for_user - get the USB drive directory (the symlink to the user's home directory), if present
#
# writes the path name to stdout
#
# Returns: 0 on success or 1 on failure
get_usb_symlink_for_user() {
  if [[ -L $HOME/USB-Drive ]]; then
    echo "$HOME/USB-Drive"
    return 0
  fi
  return 1
}

#########################################################################
#
#  FILE EDITION
#
#########################################################################
delete_line_from_file() {
  # first parameter is the string to be matched
  # the lines that contain that string will get deleted
  # second parameter is the filename
  if [ -f $2 ]
  then
    sudo sed -i "/$1/d" $2
  fi
}

insert_before_line_in_file() {
  # first argument is the line that needs to be inserted DO NOT USE PATHS WITH / in them
  # second argument is a partial match of the line we need to find to insert before
  # third arument is filename

  if [ -f $3 ]
  then
    sudo sed -i "/$2/i $1" $3
  fi
}

add_line_to_end_of_file() {
  # first parameter is what to add
  # second parameter is filename
  if [ -f $2 ]
  then
    echo "$1" >> "$2"
  fi 
}

replace_first_this_with_that_in_file() {
  # replaces the first occurence
  # first parameter is the string to be replaced
  # second parameter is the string which replaces
  # third parameter is the filename
  if grep -q "$1" $3
  then
    sudo sed -i "s/$1/$2/" "$3"
     return 0
  else
      #feedback "Line - $1 not found"
      return 1
  fi
}
replace_all_this_with_that_in_file(){
  # does a global replace
  # first argument: what needs to be replaced
  # second argument: the new stuff
  # third argument: the file in question
  # returns 0 if file exists (may or may not have succeeded in the substitution)
  # return 1 if file does not exists
  #feedback "replacing $1 with $2 in $3"
  if file_exists "$3"
  then
    sudo sed -i "s/$1/$2/g" "$3"
    return 0
  else
    return 1
  fi
}

find_in_file() {
  # first argument is what to look for
  # second argument is the filename
  if grep -q "$1" $2
  then
    return 0
  else
    return 1
  fi
}

find_in_file_strict() {
  # first argument is what to look for
  # second argument is the filename
  # looks for a complete word and not part of a word
  if grep -w -q "$1[\D]" $2
  then
    return 0
  else
    return 1
  fi
}

#########################################################################
#
#  FILE HANDLING - detection, deletion
#
#########################################################################
file_exists() {
  # Only one argument: the file to look for
  # returns 0 on SUCCESS
  # returns 1 on FAIL
  if [ -f "$1" ]
  then
    return 0
  else
    return 1
  fi
}

file_exists_in_folder(){
  # can only be run using bash, not sh
  # first argument: file to look for
  # second argument: folder path
  pushd $2 > /dev/null
  status = file_exists $1
  popd > /dev/null
  return status
}

file_does_not_exists(){
  # Only one argument: the file to look for
  # returns 0 on SUCCESS
  # returns 1 on FAIL
  if [ ! -f $1 ]
  then
    return 0
  else
    return 1
  fi
}

delete_file (){
  # One parameter only: the file to delete
  if file_exists "$1"
  then
    sudo rm "$1"
  fi
}

wget_file() {
  # One parameter: the URL of the file to wget
  # this will look if ther's already a file of the same name
  # if there's one, it will delete it before wgetting the new one
  # this is to avoid creating multiple files with .1, .2, .3 extensions
  echo $1
  # extract the filename from the provided path
  target_file=${1##*/}
  echo $target_file
  delete_file $target_file
  wget $1 --no-check-certificate


}

#########################################################################
#
#  FOLDER HANDLING - detection, deletion
#
#########################################################################
create_folder(){
  if ! folder_exists "$1"
  then
    sudo mkdir "$1"
  fi
}

folder_exists(){
  # Only one argument: the folder to look for
  # returns 0 on SUCCESS
  # returns 1 on FAIL
  if [ -d "$1" ]
  then
    return 0
  else
    return 1
  fi
}

delete_folder(){
  if folder_exists "$1"
  then
    sudo rm -r "$1"
  fi
}
