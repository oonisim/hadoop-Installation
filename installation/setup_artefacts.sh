#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Modules e.g. hadoop requires information such as where to install the master. 
# Consult the infrastructure provisioner (e.g. aws provisioner) and collect the
# cluster infrastructure information, e.g. master server IP.
# 
#├── hadoop
#│   ├── env
#│   │   └── hadoop_variables.sh
#│   └── etc
#├── os
#│   └── env
#│       └── hosts
#└── spark
#    ├── conf
#    └── env
#        └── spark_variables.sh  
#--------------------------------------------------------------------------------
set -ue

DIR=$(realpath $(dirname $0))
cd ${DIR}

. ${DIR}/_setup_env_installer.sh

#--------------------------------------------------------------------------------
# Create directories to save artefacts. 
#--------------------------------------------------------------------------------
mkdir -p ${DIR}/artefacts/{os,hadoop,spark}/env

#--------------------------------------------------------------------------------
# Cleanup previous execution results.
#--------------------------------------------------------------------------------
rm -rf   ${DIR}/artefacts/{os,hadoop,spark}/env/*

#--------------------------------------------------------------------------------
# Collect information from the infrastructure provisioner.
#--------------------------------------------------------------------------------
ansible/aws/operations/scripts/generate_menifests.sh ${TARGET_INVENTORY} ${DIR}/artefacts/{os,hadoop,spark}/env
