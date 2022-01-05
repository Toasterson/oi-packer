#!/bin/bash -eux

echo "==> Cleaning up SSH host keys"
# If the key doesn't exist, we shouldn't end with
# non-zero return code, as packer will fail.
rm /etc/ssh/ssh_host_ecdsa_key{,.pub} || true
rm /etc/ssh/ssh_host_dsa_key{,.pub} || true
rm /etc/ssh/ssh_host_rsa_key{,.pub} || true
rm /etc/ssh/ssh_host_ed25519_key{,.pub} || true

echo "==> Emptying log files from /var/adm"
find /var/adm -type f -exec cp /dev/null {} \;

echo "==> Emptying log files from /var/log"
find /var/log -type f -exec cp /dev/null {} \;
