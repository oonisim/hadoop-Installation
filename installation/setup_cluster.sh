#!/usr/bin/env bash
set -eu
DIR=$(realpath $(dirname $0))
cd ${DIR}

# Python user site
export PATH=${PATH}:${HOME}/.local/bin

#--------------------------------------------------------------------------------
# Target environment/inventory and Ansibe remote_user to use
#--------------------------------------------------------------------------------
if [ -z ${TARGET_INVENTORY+x} ]; then
    echo "What is TARGET_INVENTORY?"
    read TARGET_INVENTORY
else
    echo "TARGET_INVENTORY is ${TARGET_INVENTORY}"
fi

if [ -z ${REMOTE_USER+x} ]; then
    echo "What is REMOTE_USER?"
    read REMOTE_USER
else
    echo "REMOTE_USER is ${REMOTE_USER}"
fi

#--------------------------------------------------------------------------------
# Environment variables
#--------------------------------------------------------------------------------
. ${DIR}/_setup_env_installer.sh
. ${DIR}/_setup_env_cluster.sh

#--------------------------------------------------------------------------------
# Run Spark setup
#--------------------------------------------------------------------------------
./maintenance.sh
${DIR}/propagate_artefacts.sh
for module in $(find ./ansible/cluster -type d -maxdepth 1 -mindepth 1 | sort)
do
    ${module}/scripts/main.sh \
        ${TARGET_INVENTORY} \
        ${REMOTE_USER} 

#    if [ "${module##*/}" == "02_os" ] ; then
#        echo "waiting sever restarts"
#        sleep 10
#    fi
    sleep 10
done
