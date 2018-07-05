#!/bin/bash
#--------------------------------------------------------------------------------
# Run the ansible playbook.
#--------------------------------------------------------------------------------
set -eu

DIR=$(dirname $(realpath $0))
. ${DIR}/_utility.sh

#--------------------------------------------------------------------------------
# TARGET_INVENTORY: Target environment id
# OS_OUTPUT_DIR:     location to place the hosts file.
# HADOOP_OUTPUT_DIR: location to place the hadoop configuration files.
# SPARK_OUTPUT_DIR:  location to place the spark  configuration files.
# TASK       : List
#--------------------------------------------------------------------------------

PLAYBOOK_DIR=$(realpath "$(dirname $0)/../plays")
TASK=list

if [ $# -eq 4 ]; then
    TARGET_INVENTORY=$1
    OS_OUTPUT_DIR=$2
    HADOOP_OUTPUT_DIR=$3
    SPARK_OUTPUT_DIR=$4
else
    echo "Target environment/inventory?"
    read TARGET_INVENTORY

    echo "OS Output directory?"
    read OS_OUTPUT_DIR

    echo "Hadoop Output directory?"
    read HADOOP_OUTPUT_DIR

    echo "Spark Output directory?"
    read SPARK_OUTPUT_DIR
fi

PLAYBOOK_DIR=$(realpath "$(dirname $0)/../plays")
ARGS="\
    -e OS_OUTPUT_DIR=${OS_OUTPUT_DIR} \
    -e HADOOP_OUTPUT_DIR=${HADOOP_OUTPUT_DIR} \
    -e SPARK_OUTPUT_DIR=${SPARK_OUTPUT_DIR}"

ln -sf ${PLAYBOOK_DIR}/${TASK}.yml ${PLAYBOOK_DIR}/site.yml
$(_locate ${DIR} '/' 'conductor.sh') ${PLAYBOOK_DIR} ${TARGET_INVENTORY} ${ARGS}
rm -f  ${PLAYBOOK_DIR}/site.yml
