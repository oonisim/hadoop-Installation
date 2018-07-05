#!/usr/bin/env bash
set -ue

DIR=$(realpath $(dirname $0))
cd ${DIR}

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"Set AWS_ACCESS_KEY_ID"}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"Set AWS_SECRET_ACCESS_KEY"}
export TARGET_INVENTORY=${TARGET_INVENTORY:?"Set TARGET_INVENTORY"}


#--------------------------------------------------------------------------------
# Setup AWS and create master file which holds master node data in ${DIR}
# The master file is then used by run_k8s.sh
#--------------------------------------------------------------------------------
./maintenance.sh

rm -rf os     && mkdir -p ${DIR}/os
rm -rf hadoop && mkdir -p ${DIR}/hadoop 
rm -rf spark  && mkdir -p ${DIR}/spark

cluster/ansible/aws/ec2/operations/scripts/generate_config_files.sh ${TARGET_INVENTORY} ${DIR}/os ${DIR}/hadoop ${DIR}/spark