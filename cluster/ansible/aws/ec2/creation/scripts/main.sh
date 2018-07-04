#!/bin/bash
#--------------------------------------------------------------------------------
# Run the ansible playbook.
#--------------------------------------------------------------------------------
set -eu
DIR=$(realpath $(dirname $0))
. ${DIR}/_utility.sh

if [ $# -eq 5 ]; then
    TARGET_INVENTORY=$1
    EC2_KEYPAIR_NAME=$2
    OS_OUTPUT_DIR=$3
    HADOOP_OUTPUT_DIR=$4
    SPARK_OUTPUT_DIR=$5
else
    echo "Target environment/inventory?"
    read TARGET_INVENTORY

    echo "EC2 keypair name?"
    read EC2_KEYPAIR_NAME

    echo "OS Output directory?"
    read OS_OUTPUT_DIR

    echo "Hadoop Output directory?"
    read HADOOP_OUTPUT_DIR

    echo "Spark Output directory?"
    read SPARK_OUTPUT_DIR
fi

PLAYBOOK_DIR=$(realpath "$(dirname $0)/../plays")
ARGS="\
    -e ENV_ID=${TARGET_INVENTORY} \
    -e EC2_KEYPAIR_NAME=${EC2_KEYPAIR_NAME} \
    -e HADOOP_OUTPUT_DIR=${OS_OUTPUT_DIR} \
    -e HADOOP_OUTPUT_DIR=${HADOOP_OUTPUT_DIR} \
    -e SPARK_OUTPUT_DIR=${SPARK_OUTPUT_DIR}"

$(_locate ${DIR} '/' 'conductor.sh') ${PLAYBOOK_DIR} ${TARGET_INVENTORY} ${ARGS}
