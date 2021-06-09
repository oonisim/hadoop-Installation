#!/usr/bin/env bash
set -eu
DIR=$(realpath $(dirname $0))
cd ${DIR}

#--------------------------------------------------------------------------------
# SPARK environment
#--------------------------------------------------------------------------------
if [ -z ${SPARK_HOME+x} ]; then
    echo "What is SPARK_HOME?"
    read SPARK_HOME
    export SPARK_HOME
else
    echo "SPARK_HOME is ${SPARK_HOME}"
fi

if [ -z ${SPARK_MASTER+x} ]; then
    echo "What is SPARK_MASTER?"
    read SPARK_MASTER
    export SPARK_MASTER
else
    echo "SPARK_MASTER is ${SPARK_MASTER}"
fi

#--------------------------------------------------------------------------------
# Conda environment
#--------------------------------------------------------------------------------
if [ -z ${CONDA_ENVIRONMENT+x} ]; then
    echo "What is CONDA_ENVIRONMENT?"
    read CONDA_ENVIRONMENT
    export CONDA_ENVIRONMENT
else
    echo "CONDA_ENVIRONMENT is ${CONDA_ENVIRONMENT}"
fi

conda create -n ${CONDA_ENVIRONMENT} python=3.8
conda activate ${CONDA_ENVIRONMENT}
conda install jupyter notebook

pip3 install --upgrade toree
jupyter toree install --spark_home=${SPARK_HOME} --interpreters=Scala,PySpark,SQL --user
#SPARK_OPTS='--master=local[*]' jupyter notebook
#SPARK_OPTS="--master spark://${SPARK_MASTER}:7077 --deploy-mode client --num-executors 2 --driver-memory 2g --executor-memory 4g --executor-cores 4" jupyter notebook
