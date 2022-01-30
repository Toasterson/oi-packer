#!/usr/bin/bash
set -ex

pkg install -v gcc-11 system/header git

git clone https://github.com/Toasterson/metadata-agent.git metadata-agent

wget https://static.rust-lang.org/dist/rust-1.58.1-x86_64-unknown-illumos.tar.gz

tar -xzf rust-1.58.1-x86_64-unknown-illumos.tar.gz

./rust-1.58.1-x86_64-unknown-illumos/install.sh

cd metadata-agent

MODE=release make install

# Setup OS to run console con COM0
cat <<EOF > /boot/conf.d/cloud-init-serial.conf
console="ttya"
autoboot_delay="-1"
EOF
