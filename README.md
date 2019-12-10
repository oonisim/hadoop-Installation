Spark/Hadoop YARN cluster deployment using Ansible
=========

Approach
------------
* Dependency should be injected. 
* Separation of concerns - Each module must not know about the details of other modules.

AWS Network Topology
------------
Simple 1 master + 2 workers (can be increased by a parameter) in a VPC subnet, to be created by the Ansible playbooks.

<img src="https://github.com/oonisim/Apache-Spark-Installation/blob/master/Images/AWS.png">

Repository Structure
------------

### Overview

Ansible playbooks and inventories. To install in AWS, use aws inventory, or use local for local PC installation.

```
.
├── installation    <---- Hadoop+Spark cluster installation home (on AWS or local)
│   ├── ansible     <---- Ansible playbook directory
│   │   ├── aws
│   │   │   ├── creation             <---- Module to create AWS environment
│   │   │   ├── operations
│   │   │   ├── conductor.sh
│   │   │   └── player.sh
│   │   └── cluster
│   │       ├── 01_prerequisite      <---- Module to setup Ansible pre-requisites
│   │       ├── 02_os                <---- Module to setup OS to install Spark
│   │       ├── 02_packages          <---- Module to setup software packages
│   │       ├── 20_hadoop            <---- Module to setup Hadoop/YARN cluster
│   │       ├── 30_spark             <---- Module to setup Spark cluster
│   │       ├── 40_spark             <---- Module to run Spark applications (naive bayes, etc)
│   │       ├── 510datadog           <---- Module to setup datadog monitoring (option)
│   │       ├── conductor.sh         <---- Script to conduct playbook executions
│   │       └── player.sh            <---- Playbook player (to be used to decrypt Ansible vault key)
│   ├── conf
│   │   └── ansible          <---- Ansible configuration directory
│   │       ├── ansible.cfg  <---- Configurations for all plays
│   │       └── inventories  <---- Each environment has it inventory here
│   │           ├── aws      <---- AWS environment inventory
│   │           ├── local    <---- local environment inventory
│   │           └── template
│   └── tools
├── master        <---- Spark master node data for run_Spark.s created by setup_aws.sh or update manally.
├── setup.sh      <---- Run setup_aws.sh and run_Spark.sh
├── setup_aws.sh  <---- Run AWS setups
└── run.sh        <---- Run setups
```

#### Module and structure

Module is a set of playbooks to execute a specific task e.g. 30_spark is to setup a Spark cluster. Each module directory has the same structure having plays and scripts.
```
30_spark/
├── Readme.md         <---- (option) description of the module
├── plays
│   ├── roles
│   │   ├── common    <---- Common tasks for both master and workers
│   │   ├── master    <---- Setup master node
│   │   └── worker    <---- Setup worker nodes
│   ├── site.yml
│   ├── masters.yml   <--- playbook for master node
│   └── workers.yml   <--- playbook for worker nodes
└── scripts
    └── main.sh       <---- script to run the module (each module can run separately/repeatedly)
```
---

# Prerequisite

Python and Pip. Some Python packages would require installations using the Linux distribution package manager.

# AWS

To create an AWS environment to deploy Hadoop + Spark.

## Ansible master

### AWS CLI
Prepare EC2 keypair, install AWS CLI (use --user) and set the environment variables. Make sure to set ~/.local/bin to PATH to use local python site.

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* EC2_KEYPAIR_NAME         <---- AWS SSH keypair name
* REMOTE_USER              <---- AWS EC2 user (centos for CentOs, ec2-user for RHEL)

### Ansible
Install the latest Ansible and Boto (botocore + boto3) with pip (--user). If the host is RHEL/CentOS/Ubuntu, run below will setup Ansible.

```
(cd ./installation/ansible/cluster/01_prerequisite/scripts && ./setup.sh)
```

Test the Ansible AWS dynamic inventory script. Make sure to have the [latest script](https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py). 
```
installation/conf/ansible/inventories/aws/inventory/ec2.py
```

### SSH
Configure ssh-agent and/or .ssh/config with the AWS SSH PEM to be able to SSH into the targets without providing pass phrase. Create a test EC2 instance and test.

```
eval $(ssh-agent)
ssh-add <AWS SSH pem>
ssh ${REMOTE_USER}@<EC2 server> sudo ls  # no prompt for asking password
```

## Execution

Run below and it will ask for the location to save the auto-generated files.

```aidl
installation/setup_aws.sh
```

---

# Hadoop/YARN & Spark

## Ansible master
### Environment variables

Update hadoop_variables.sh and spark_variables.sh so that ./installation/_setup_env_cluster.sh setups the environment variables for the installation.
```
export $(cat ${DIR}/conf/ansible/inventories/${TARGET_INVENTORY}/env/hadoop/env/hadoop_variables.sh | grep -v '^#' | xargs)
export $(cat ${DIR}/conf/ansible/inventories/${TARGET_INVENTORY}/env/spark/env/spark_variables.sh   | grep -v '^#' | xargs)
```

#### REMOTE_USER
Update REMOTE_USER with the Linux account name to SSH login into the Ansible targets who can sudo without password as the Ansible remote_user to run the playbooks.

#### TARGET_INVENTORY
Update TARGET_INVENTORY with the inventory name with the Ansible inventory name.

### Configuration parameters

Parameters for an environment are all isolated in group_vars of the environment inventory. Go through the group_vars files to set values.

```
.
├── conf    <----- CONF_DIR environment variable
│   └── ansible
│      ├── ansible.cfg
│      └── inventories
│           └── aws
│               ├── group_vars
│               │   ├── all             <---- Configure properties in the 'all' group vars
│               │   │   ├── env.yml     <---- Enviornment parameters e.g. ENV_ID to identify and to tag configuration items
│               │   │   ├── server.yml  <---- Server parameters
│               │   │   ├── aws.yml     <---- e.g. AMI image id, volume type, etc
│               │   │   ├── spark.yml   <---- Spark configurations
│               │   │   └── datadog.yml
│               │   ├── masters         <---- For master group specifics
│               │   └── workers
│               └── inventory
│                   ├── ec2.ini
│                   ├── ec2.py
│                   └── hosts           <---- Target node(s) using tag values (set upon creating AWS env)
├── tools   <----- TOOL_DIR environment variable 
```
#### Hadoop 

Update the installation/conf/ansible/inventories/${TARGET_INVENTORY}/group_vars/all/21.hadoop.yml for:

* HADOOP_VERSION
* HADOOP_PACKAGE_CHECKSUM

```
installation/conf/ansible/inventories/${TARGET_INVENTORY}/group_vars/all/21.hadoop.yml
```

#### SPARK
Update the installation/conf/ansible/inventories/${TARGET_INVENTORY}/group_vars/all/31.spark.yml for:

* SPARK_VERSION
* SPARK_PACKAGE_CHECKSUM
* SPARK_SCALA_VERSION     <---- Scala versoin used to compile the Spark package

#### Datadog (optional & AWS only)

Create a Datadog trial account and set the environment variable DATADOG_API_KEY to the [Datadog account API_KEY](https://app.datadoghq.com/account/settings#api). The Datadog module setups the monitors/metrics to verify that Spark is up and running, and can start monitoring and setup alerts right away.
Update installation/conf/ansible/inventories/${TARGET_INVENTORY}/group_vars/all/51.datadog.yml for other parameters.

#### Master node information
Set **private** AWS DNS name and IP of the master node instance. If setup_aws.sh is used, it creates a file **master** which includes them and run_Spark.sh uses them. Otherwise set them in env.yml and as environment variables after having created the AWS instances.

* MASTER_HOSTNAME
* MASTER_NODE_IP

#### SPARK_ADMIN and HADOOP_USERS
Set an account name to SPARK_ADMIN in server.yml. The account is created by a playbook via HADOOP_USERS in server.yml. Set an encrypted password in the corresponding field. Use [mkpasswd as explained in Ansible document](http://docs.ansible.com/ansible/latest/faq.html#how-do-i-generate-crypted-passwords-for-the-user-module).


Executions
------------
Make sure the environment variables are set.

Environment variables:
* TARGET_INVENTORY
* REMOTE_USER
* AWS_ACCESS_KEY_ID       (for AWS only)
* AWS_SECRET_ACCESS_KEY   (for AWS only)
* EC2_KEYPAIR_NAME        (for AWS only)
* DATADOG_API_KEY         (for AWS only)


### Hadoop + Spark
In the directory, run run_Spark.sh. If DATADOG_API_KEY is not set, the 51_datadog module will cause errors.

```
.
├── cluster
├── maintenance.sh
├── setup.sh
├── setup_aws.sh
└── setup_cluster.sh   <---- Run this script
```

Alternatively, run each module one by one, and skip 51_datadog if not using.
```
pushd ansible/Spark/<module>/scripts && ./main.sh or
ansible/Spark/<module>/scripts/main.sh aws <ansible remote_user>
```

Modules are:
```
├── 01_prerequisite      <---- Module to setup Ansible pre-requisites
├── 02_os                <---- Module to setup OS to install Spark
├── 03_packages          <---- Module to setup OS to install Spark
├── 20_hadoop            <---- Module to setup Spark cluster
├── 30_spark             <---- Module to setup Spark cluster
├── 40_application       <---- Module to run Spark applications
├── 50_datadog           <---- Module to setup datadog monitoring (option)
├── conductor.sh         <---- Script to conduct playbook executions
└── player.sh            <---- Playbook player
```


---

# Hadoop 

## Environment variables

To propagate environment variables, place /etc/profile.d/.
For Ubuntu, update bash.bashrc.
* [Scripts in /etc/profile.d Being Ignored?](https://askubuntu.com/questions/438150/scripts-in-etc-profile-d-being-ignored/438170)

See:
```
installation/ansible/cluster/20_hadoop/plays/roles/common/tasks/bash.yml
installation/ansible/cluster/20_hadoop/plays/roles/common/templates/profile.d/hadoop.sh.j2
```

## configurations

### mapreduce-site.xml
```aidl
<configuration>
    <property>
      <name>mapreduce.framework.name</name>
      <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.map.memory.mb</name>
        <value>{{ YARN_MR_MAP_MEMORY_MB }}</value>
    </property>
    <property>
        <name>mapreduce.map.java.opts</name>
        <value>{{ YARN_MR_MAP_JAVA_OPTS }}</value>
    </property>
    <property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>{{ YARN_MR_REDUCE_MEMORY_MB }}</value>
    </property>
    <property>
        <name>mapreduce.reduce.java.opts</name>
        <value>{{ YARN_MR_REDUCE_JAVA_OPTS }}</value>
    </property>

   <!--
  Without below, Error: Could not find or load main class org.apache.hadoop.mapreduce.v2.app.MRAppMaster .
  See https://stackoverflow.com/questions/50927577/could-not-find-or-load-main-class-org-apache-hadoop-mapreduce-v2-app-mrappmaster as well.
   -->
    <property>
      <name>yarn.app.mapreduce.am.env</name>
      <value>HADOOP_MAPRED_HOME={{ HADOOP_HOME }}</value>
    </property>
    <property>
      <name>mapreduce.map.env</name>
      <value>HADOOP_MAPRED_HOME={{ HADOOP_HOME }}</value>
    </property>
    <property>
      <name>mapreduce.reduce.env</name>
      <value>HADOOP_MAPRED_HOME={{ HADOOP_HOME }}</value>
    </property>

</configuration>

```

# Spark
## Configurations

Hadoop configuration files are required for Spark to access Hadoop/Yarn. Set the environment variables referring to the Hadoop/Yarn configuration directories.

* HADOOP_CONF_DIR
* YARN_CONF_DIR

