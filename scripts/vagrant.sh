#!/bin/bash -eux

echo '==> Configuring settings for vagrant'

VAGRANT_USER=${VAGRANT_USER:-vagrant}
VAGRANT_HOME=${VAGRANT_HOME:-/export/home/${VAGRANT_USER}}

# Add vagrant user (if it doesn't already exist)
if ! id -u "${VAGRANT_USER}" >/dev/null 2>&1; then
    echo "==> Creating ${VAGRANT_USER}"
    /usr/sbin/groupadd "${VAGRANT_USER}"
    /usr/sbin/useradd -s /usr/bin/bash -m -d "${VAGRANT_HOME}" -g "${VAGRANT_USER}" "${VAGRANT_USER}"
    /usr/bin/passwd -N "${VAGRANT_USER}"

    echo "==> Giving ${VAGRANT_USER} sudo powers"
    echo "${VAGRANT_USER}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
    echo 'Defaults env_keep += "SSH_AUTH_SOCK"' >> /etc/sudoers

    echo "==> Giving ${VAGRANT_USER} pfexec powers"
    /usr/sbin/usermod -P 'Primary Administrator' "${VAGRANT_USER}"
fi

echo '==> Enabling Vagrant authorized Keys file'
echo '.ssh/authorized_keys.temp .ssh/authorized_keys .ssh/authorized_keys2' >> /etc/ssh/sshd_config

echo '==> Installing Vagrant SSH key'
mkdir -p "${VAGRANT_HOME}/.ssh"
chmod 700 "${VAGRANT_HOME}/.ssh"

mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Download current vagrant ssh keys to authorized_keys
curl https://raw.githubusercontent.com/hashicorp/vagrant/refs/heads/main/keys/vagrant.pub > "${VAGRANT_HOME}/.ssh/authorized_keys"
curl https://raw.githubusercontent.com/hashicorp/vagrant/refs/heads/main/keys/vagrant.pub > /root/.ssh/authorized_keys

chmod 0600 "${VAGRANT_HOME}/.ssh/authorized_keys"
chown -R "${VAGRANT_USER}:${VAGRANT_USER}" "${VAGRANT_HOME}/.ssh"

echo '==> Recording box config date'
date > /etc/vagrant_box_build_time

echo '==> Set DNS to known non interupting defaults'
# See https://wiki.ipfire.org/dns/public-servers for details
# Chosen servers are Digitalcourage e.V. and Cloudflare
cat << EOF > /etc/resolv.conf
nameserver 46.182.19.48
nameserver 1.1.1.1
EOF