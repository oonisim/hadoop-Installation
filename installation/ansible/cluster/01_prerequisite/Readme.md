## Objective
This module is to setup the ansible pre-requisites on the ansible master and the target nodes.

## Structure
.
├── Readme.md
├── plays
│   ├── roles
│   │   └── python            <----- Setup ansible pre-requisite (python 2.x) on the target nodes.
│   └── site.yml
└── scripts
    ├── python_requirements   <----- Python requirement to setup the ansible master.
    ├── _redhat.sh            <----- Setup RHEL/CentOS   ansible master
    ├── _ubuntu.sh            <----- Setup Debian/Ubuntu ansible master
    ├── setup.sh              <----- Setup the ansible master to be able to execute Ansible
    ├── setup_ansible_user.sh <----- Setup the ansible remote user to ssh into the target
    └── main.sh               <----- Setup the target nodes


## setup_ansible_user.sh

Ansible requires SSH to log into the target machines. To setup the SSH user (ansible_user or REMOTE_USER) in the target machines for Ansible to use, run the script in the target machine.
