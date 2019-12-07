#!/bin/bash
#--------------------------------------------------------------------------------
# Run on the Ansible target machine.
# Setup the REMOTE_USER that Ansible master use to ssh-into the target.
#--------------------------------------------------------------------------------
set -u

USER='ansible'
GROUP='ansible'
SUDO_GROUP='sudo'

#--------------------------------------------------------------------------------
# Account setup
#--------------------------------------------------------------------------------
if [ $(getent group ${GROUP}) ]; then
  echo "group ${GROUP} exists."
else
  sudo groupadd ${GROUP}
fi
if [ $(getent passwd ${USER}) ]; then
  echo "user ${USER} exists."
else
  sudo useradd -m -s /bin/bash -G ${SUDO_GROUP} -g ${GROUP} ${USER}
fi

#--------------------------------------------------------------------------------
# SSH public authentication setup
#--------------------------------------------------------------------------------
echo "Provide public key text>"
read key

AUTH_KEY_DIR="$(sudo -i -u ${USER} pwd)/.ssh"
AUTH_KEY_FILE="${AUTH_KEY_DIR}/authorized_keys"
sudo -i -u ${USER} mkdir -p ${AUTH_KEY_DIR}
sudo -i -u ${USER} touch    ${AUTH_KEY_FILE}

sudo -i -u ${USER} grep -q -F "${key}" ${AUTH_KEY_FILE}
if [ $? -ne 0  ]; then
   sudo -i -u ${USER} /bin/bash -c "echo ${key} >> ${AUTH_KEY_FILE}"
fi

sudo -i -u ${USER} chmod -R go-rwx ${AUTH_KEY_DIR}

#--------------------------------------------------------------------------------
# Sudoers setup
#--------------------------------------------------------------------------------
echo "${USER} ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${USER}

echo "done"