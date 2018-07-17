#!/bin/bash
#--------------------------------------------------------------------------------
# Run the ansible playbook.
#--------------------------------------------------------------------------------
set -eu
DIR=$(realpath $(dirname $0))
. ${DIR}/_utility.sh

if [ $# -eq 2 ]; then
    TARGET_INVENTORY=$1
    EC2_KEYPAIR_NAME=$2
else
    echo "Target environment/inventory?"
    read TARGET_INVENTORY

    echo "EC2 keypair name?"
    read EC2_KEYPAIR_NAME
fi

PLAYBOOK_DIR=$(realpath "$(dirname $0)/../plays")
ARGS="\
    -e ENV_ID=${TARGET_INVENTORY} \
    -e EC2_KEYPAIR_NAME=${EC2_KEYPAIR_NAME}"

$(_locate ${DIR} '/' 'conductor.sh') ${PLAYBOOK_DIR} ${TARGET_INVENTORY} ${ARGS}
