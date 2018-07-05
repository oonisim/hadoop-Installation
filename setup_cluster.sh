#!/usr/bin/env bash
set -eu
DIR=$(realpath $(dirname $0))
cd ${DIR}

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
# AWS information
# Not asking to type credentials from command line.
#--------------------------------------------------------------------------------
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"Set AWS_ACCESS_KEY_ID"}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"Set AWS_SECRET_ACCESS_KEY"}

#--------------------------------------------------------------------------------
# Generate hosts file (/etc/hosts) from the EC2 instances created.
#--------------------------------------------------------------------------------
cp os/hosts  ${DIR}/cluster/ansible/cluster/02_os/plays/roles/hosts/files/hosts
cp -r hadoop ${DIR}/cluster/ansible/cluster/11_hadoop/plays/roles/master/files/
cp -r hadoop ${DIR}/cluster/ansible/cluster/11_hadoop/plays/roles/worker/files/
cp -r spark  ${DIR}/cluster/ansible/cluster/21_spark/plays/roles/master/files/

#--------------------------------------------------------------------------------
# Run Spark setup
#--------------------------------------------------------------------------------
./maintenance.sh
for module in $(find ./cluster/ansible/cluster -type d -maxdepth 1 -mindepth 1)
do
    if [ "${module##*/}" == "51_datadog" ] ; then
        continue
    fi

    ${module}/scripts/main.sh \
        ${TARGET_INVENTORY} \
        ${REMOTE_USER} 

    if [ "${module##*/}" == "02_os" ] ; then
        echo "waiting sever restarts"
        sleep 10
    fi
done
