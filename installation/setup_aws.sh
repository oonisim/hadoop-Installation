#!/usr/bin/env bash
set -ue

DIR=$(realpath $(dirname $0))
cd ${DIR}

. ${DIR}/_setup_env_installer.sh
. ${DIR}/_setup_env_aws.sh

export TARGET_INVENTORY=${TARGET_INVENTORY:?"Set TARGET_INVENTORY"}

#--------------------------------------------------------------------------------
# Setup AWS and create master file which holds master node data in ${DIR}
# The master file is then used by run_k8s.sh
#--------------------------------------------------------------------------------
./maintenance.sh

ansible/aws/creation/scripts/main.sh ${TARGET_INVENTORY} ${EC2_KEYPAIR_NAME}