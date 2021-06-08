Spark/Hadoop YARN cluster deployment using Ansible
=========

## Objective
Setup Spark/Hadoop YARN cluster with Ansible in an environment (either AWS, on-premise, or local PC).

### Approach
* Dependency should be injected  
Use environment variables to specify the runtime nodes e.g. master node host. 

* Separation of concerns - Each module must NOT know about the details of other modules.

### Prerequisite

Ansible requires Python and pip both Ansible master and target nodes. Some Python packages would require installations using the Linux distribution package manager.


Topology
------------
Simple 1 master + N workers (N can be increased by a parameter) in a subnet. Master redundancy is not implemented. AWS environment can be created by the Ansible playbooks.

<img src="documentation/Images/AWS.png">

Repository Structure
------------

### Overview

Ansible playbooks and inventories. To install in AWS, use aws inventory, or use local for local PC installation.

```
.
├── installation    <---- Hadoop+Spark cluster installation home (on AWS or local)
│   ├── ansible     <---- Ansible playbook directory
│   │   ├── aws
│   │   │   ├── creation             <---- Module to create AWS environment (optional: to create an AWS environment)
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

#### Inventory
Ansible manages a group of nodes in an environment in a unit called [Inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html). For each environment, an inventory directory is defined in the directory. 
```
installation/conf/ansible/inventories/
```

For instance, to manage a local PC environment named 'local', create the directory **local** and set **local** to the TARGET_INVENTORY environment variable.
```
installation/conf/ansible/inventories/local
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


### Configurations

Parameters for a TARGET_INVENTORY is isolated in group_vars for the inventory.
```
.
├── conf    <----- CONF_DIR environment variable
│   └── ansible
│      ├── ansible.cfg
│      └── inventories
│           └── aws                     <---- For an AWS environment
│               ├── group_vars
│               │   ├── all             <---- Configure properties in the 'all' group vars
│               │   │   ├── env.yml     <---- Enviornment parameters e.g. ENV_ID to identify and to tag configuration items
│               │   │   ├── server.yml  <---- Server parameters
│               │   │   ├── aws.yml     <---- e.g. AMI image id, volume type, etc (AWS only)
│               │   │   ├── spark.yml   <---- Spark configurations
│               │   │   └── datadog.yml <---- Optional for Datadog (AWS only)
│               │   ├── masters         <---- For master group specifics
│               │   └── workers
│               └── inventory
│                   ├── ec2.ini         <---- Ansible dynamic inventory configurations (AWS only)
│                   ├── ec2.py          <---- Ansible dynamic inventory script (AWS only)
│                   └── hosts           <---- Target node(s) using tag values (For AWS, auto-configured upon creating AWS environment)
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
<pre>
SPARK_VERSION
SPARK_PACKAGE_CHECKSUM
SPARK_SCALA_VERSION     <---- Scala versoin used to compile the Spark package
SPARK_MASTER            <---- Spark master e.g. local, yarn, etc.
SPARK_DEPLOY_MODE       <---- Spark deployment mode e.g. cluster or client.
SPARK_DRIVER_MEMORY     <---- Default Spark driver memory.
</pre>

#### SPARK_ADMIN and HADOOP_USERS
Set an account name to SPARK_ADMIN in server.yml. The account is created by a playbook via HADOOP_USERS in server.yml. Set an encrypted password in the corresponding field. Use [mkpasswd as explained in Ansible document](http://docs.ansible.com/ansible/latest/faq.html#how-do-i-generate-crypted-passwords-for-the-user-module).


#### Datadog (optional & AWS only)

Create a Datadog trial account and set the environment variable DATADOG_API_KEY to the [Datadog account API_KEY](https://app.datadoghq.com/account/settings#api). The Datadog module setups the monitors/metrics to verify that Spark is up and running, and can start monitoring and setup alerts right away.
Update installation/conf/ansible/inventories/${TARGET_INVENTORY}/group_vars/all/51.datadog.yml for other parameters.


---
# Preparations

# Local

## Ansible targets

### SSH
#### SSH Server
Run a SSH server and let it accept the public key authentication. May better to disable password authentication once key setup is done.

### Ansible account
Make sure to have an account to run ansible playbooks on the targets. Run the script on the targets which also looks after the authorized_key part. It will ask for SSH public key to be able to login as the ansible account. Prepare it in advance.

```
./installation/ansible/cluster/01_prerequisite/scripts/setup_ansible_user.sh
```

#### pip
pip needs to be available for the ansible account to use Ansible pip module.

**Tried to use ansible user local pip but did not work. Hence using system pip.**

For instance, to install pip3 on Ubuntu.
```
apt install -fqy python3-pip
```

<br/>


## Ansible master
### MacOS
To be able to use [realpath](https://stackoverflow.com/questions/3572030/bash-script-absolute-path-with-osx).
```
brew install coreutils
```

### Python
Ansible itself relies on Python. Use Python 3 as Python 2 is end of support.

### pip

Install Ansible relies on pip. See [PyPA pip installation](https://pip.pypa.io/en/stable/installing/).
pip installation is looked after in the 01_prerequisite module setup.sh via get-pip.py.
```
./installation/ansible/cluster/01_prerequisite/scripts/setup.sh
```

### Ansible
Install the latest Ansible with pip. If the host is RHEL/CentOS/Ubuntu, run below will setup Ansible.

```
(cd ./installation/ansible/cluster/01_prerequisite/scripts && ./setup.sh)
```

#### Vault password
Set the password to decrypt Ansible valut in the file.
```
~/.ansible/.vault_pass.txt
```

#### Auto-login to Ansible targets

```
ssh-copy-id -i ${SSH_PRIVATE_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST}
```

This will setup ~/.ssh/authorized_keys in the target servers so that the ansible master to be able to ssh into.


### SSH

#### Silent
Configure ssh-agent and/or .ssh/config with the SSH key to be able to SSH into the targets without providing pass phrase.

```
eval $(ssh-agent)
ssh-add <SSH key>
ssh ${REMOTE_USER}@<server> sudo ls  # no prompt for asking password
```


# AWS

This section is optional. Only when you needs to create an AWS environment to deploy Hadoop + Spark.

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

#### TARGET_INVENTORY
Update TARGET_INVENTORY with the inventory name with the Ansible inventory name.

#### REMOTE_USER
Update REMOTE_USER with the Linux account name to SSH login into the Ansible targets who can sudo without password as the Ansible remote_user to run the playbooks. 

Ansible master needs to SSH login to the target nodes with the user without providing a password (use public key authentication and ssh-agent), and have the permission to sudo without providing an password (configure /etc/sudoers for the user).

#### Spark/Hadoop
Update hadoop_variables.sh and spark_variables.sh for the TARGET_INVENTORY. 

```
HADOOP_WORKERS
HADOOP_NN_HOSTNAME
YARN_RM_HOSTNAME
SPARK_WORKERS
SPARK_MASTER_HOSTNAME
SPARK_MASTER_IP
```

```
installation/conf/ansible/inventories/${TARGET_INVENTORY}/env/hadoop/env/hadoop_variables.sh
installation/conf/ansible/inventories/${TARGET_INVENTORY}/env/spark/env/spark_variables.sh
```

The ./installation/_setup_env_cluster.sh exports the variables as environment variables.

```
export $(cat ${DIR}/conf/ansible/inventories/${TARGET_INVENTORY}/env/hadoop/env/hadoop_variables.sh | grep -v '^#' | xargs)
export $(cat ${DIR}/conf/ansible/inventories/${TARGET_INVENTORY}/env/spark/env/spark_variables.sh   | grep -v '^#' | xargs)
```

# Execution
Make sure the environment variables are set.

Environment variables:
* TARGET_INVENTORY
* REMOTE_USER
* AWS_ACCESS_KEY_ID       (for AWS only)
* AWS_SECRET_ACCESS_KEY   (for AWS only)
* EC2_KEYPAIR_NAME        (for AWS only)
* DATADOG_API_KEY         (for AWS only)


### Hadoop + Spark
Run ./installation/run_cluster.sh. If DATADOG_API_KEY is not set, the 51_datadog module will cause errors.

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
export HADOOP_WORKERS="<worker hosts>"
HADOOP_NN_HOSTNAME="<name node host>"
YARN_RM_HOSTNAME="<yarn resource manager host>"
SPARK_WORKERS="<spark worker hosts>"
SPARK_MASTER_HOSTNAME="<spark master host>"
SPARK_MASTER_IP="<spark master IP to be set in /etc/hosts file>"  # Not required for local deployment

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
# Configuration details
## Hadoop 

### Hadoop environment variables in runtime environment

To setup environment variables such as HADOOP_HOME, setup /etc/profile.d/hadoop.sh in each node. For Ubuntu, update /etc/bash.bashrc.
* [Scripts in /etc/profile.d Being Ignored?](https://askubuntu.com/questions/438150/scripts-in-etc-profile-d-being-ignored/438170)

See:
```
installation/ansible/cluster/20_hadoop/plays/roles/common/tasks/bash.yml
installation/ansible/cluster/20_hadoop/plays/roles/common/templates/profile.d/hadoop.sh.j2
```

### Hadoop configuration files

Setup files under ${HADOOP_HOME}/etc/hadoop by copying files under ./installation/ansible/cluster/20_hadoop/plays/roles/common/templates/etc via Ansible template replacing the variables.
e.g. mapreduce-site.xml
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

## Spark

### Spark master
Spark master is specified installation/ansible/cluster/30_spark/plays/roles/common/templates/conf/spark-defaults.conf.


###  Hadoop configuration files

Hadoop configuration files are required as in [Launching Spark on YARN](https://spark.apache.org/docs/latest/running-on-yarn.html#launching-spark-on-yarn) for Spark to access Hadoop/Yarn. 

See Spark Documentation - [Spark Configuration](https://spark.apache.org/docs/latest/configuration.html#inheriting-hadoop-cluster-configuration).
>To read and write from HDFS using Spark, there are two Hadoop configuration files that should be included on Spark’s classpath:
hdfs-site.xml, which provides default behaviors for the HDFS client.
core-site.xml, which sets the default filesystem name.

> To make these files visible to Spark, set HADOOP_CONF_DIR in $SPARK_HOME/conf/spark-env.sh to a location containing the configuration files.

> Note that conf/spark-env.sh does not exist by default when Spark is installed. However, you can copy conf/spark-env.sh.template to create it. **Make sure you make the copy executable**.

The files are copied to the ${HADOOP_CONF_DIR} on the Spark nodes. See:

```aidl
installation/ansible/cluster/30_spark/plays/roles/common/tasks/hadoop.yml
```

#### YARN configuration parameters

See [Running Spark on YARN - Spark properties](http://spark.apache.org/docs/latest/running-on-yarn.html#spark-properties)

#### Environment variables for Hadoop
Environment variables referring to the Hadoop/Yarn configuration directories in the Spark nodes are setup via the /etc/profile.d/spark.sh.

TODO: Move to ${SPARK_HOME}/conf/spark-env.sh

```
HADOOP_CONF_DIR
YARN_CONF_DIR
```

See:
```
installation/ansible/cluster/30_spark/plays/roles/common/templates/profile.d
```

