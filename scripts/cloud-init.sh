#!/usr/bin/bash
set -ex

pkg install -v gcc-11 system/header git

git clone https://github.com/Toasterson/metadata-agent.git metadata-agent

# Portable rust installation based on
# https://www.codejam.info/2015/03/portable-rust-installation.html

wget https://static.rust-lang.org/dist/rust-1.58.1-x86_64-unknown-illumos.tar.gz

tar -xzf rust-1.58.1-x86_64-unknown-illumos.tar.gz

mv rust-1.58.1-x86_64-unknown-illumos /opt/rust

export LD_LIBRARY_PATH=~/opt/rust/rustc/lib:$LD_LIBRARY_PATH
export PATH=~/opt/rust/rustc/bin:$PATH
export PATH=~/opt/rust/cargo/bin:$PATH

cd metadata-agent

MODE=release gmake install

# Setup OS to run console on COM0
cat <<EOF > /boot/conf.d/cloud-init-serial.conf
console="ttya"
autoboot_delay="-1"
EOF

rm -rf /opt/rust
rm -rf /root/metadata-agent
