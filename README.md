# Description
Common installation scripts used in multiple products around the Dexter Industries Galaxy of products.

# Installing

The most basic command used for updating/installing script_tools can be:
```
curl -kL dexterindustries.com/update_tools | bash
```

The above command installs the python package with user-level permissions on the system-wide environment - which does not work on most distributions unless a virtual environment is used.

The options for the python package that can be appended to this command are (all these 3 options **are mutually exclusive**):

* `--system-wide` - uses `sudo` for installing the python package system-wide.

* `--user-local` - for installing the python package in the home directory of the given user, where no special write/read/execute permissions are required.

* `--env-local` - for installing the python package system-wide, but without any special write/read/execute permissions - in order to use this you'll need a virtual environment.

On different distributions, Python 3 can only be used with `python3` command, in which case option `--use-python3-command-too` is required.

The options that can be added for apt-get/deb packages are:

* `update-aptget` - will run `sudo apt-get update`.
* `--install-deb-debs` - will run the `sudo apt-get install [dependencies]` command which installs the general dependencies.

Also, to this install script you can specify a tag or a branch you want to use, just by passing the name of it. Branches must have this format (`master`, `develop`, `feature/*`, `hotfix/*`, `fix/`) whereas tags can have this format (`v*` or `DexterOS*`).
**By default, `master` branch is pulled.**

# Installation Examples

To install the python package with `sudo` and skip installing apt-get packages (though in this case `--system-wide` can be omitted because it's turned on by default):
```
curl -kL dexterindustries.com/update_tools | bash -s --system-wide
```

To install the python package locally in the home directory and skip installing apt-get packages:
```
curl -kL dexterindustries.com/update_tools | bash -s --user-local
```

To install the python package locally in the home directory, run apt-get update and install apt-get dependencies:
```
curl -kL dexterindustries.com/update_tools | bash -s --user-local --update-aptget --install-deb-deps
```

To install the python package system-wide and take the version that's pointed by tag `DexterOS2.0`:
```
curl -kL dexterindustries.com/update_tools | bash -s DexterOS2.0
```
Or if we want the version that's on `develop` branch we can do:
```
curl -kL dexterindustries.com/update_tools | bash -s develop
```
To install packages for `python` and `python3` executables/commands, you can do this:
```
curl -kL dexterindustries.com/update_tools | bash -s --use-python3-command-too
```

# Updating

For updating the package, you can use the same commands describe at the previous section.
