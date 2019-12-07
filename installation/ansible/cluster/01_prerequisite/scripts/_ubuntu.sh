#!/bin/bash
#--------------------------------------------------------------------------------
# Apt
#--------------------------------------------------------------------------------
sudo apt update -qy
sudo apt install -y apt-file

#================================================================================
# Python
#================================================================================
sudo apt install -y build-essential libssl-dev libffi-dev python-dev python-setuptools cowsay

# --------------------------------------------------------------------------------
# To fix the issue of pip ImportError: cannot import name main
# https://stackoverflow.com/questions/49836676/error-after-upgrading-pip-cannot-import-name-main
# --------------------------------------------------------------------------------
sudo python3 -m pip uninstall -y pip && sudo apt install -y python3-pip --reinstall
sudo python -m pip uninstall -y pip && sudo apt install -y python-pip --reinstall
#sudo apt install -y python-pip
# --------------------------------------------------------------------------------

# Ubuntu has removed easy_install
# https://launchpad.net/ubuntu/+source/python-setuptools/39.0.1-2
#sudo easy_install pip

# --------------------------------------------------------------------------------
# To avoid ImportError: No module named DistUtilsExtra.command, use package manager
# instead of pip.
# https://askubuntu.com/questions/584857/distutilsextra-problem
# --------------------------------------------------------------------------------
sudo apt install -y python-apt

# --------------------------------------------------------------------------------
# Debian decided to actively exclude distutils from the default python.
# https://github.com/pypa/get-pip/issues/43
# --------------------------------------------------------------------------------
sudo apt-get install -y python3-distutils

# --------------------------------------------------------------------------------
# To avoid ERROR: launchpadlib 1.10.6 requires testresources, which is not installed.
# --------------------------------------------------------------------------------
sudo apt install -y python3-testresources

#================================================================================
# SSH
#================================================================================
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
