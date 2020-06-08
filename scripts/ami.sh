#!/usr/bin/bash -eux

echo '==> setting up AMI customisations'

cat << EOM > /boot/conf.d/autoboot.conf
autoboot_delay=1
EOM

sed -i '/e1000g/d' /etc/path_to_inst
sed -i '/vioif/d' /etc/path_to_inst

mkdir /root/.ssh
chmod 700 /root/.ssh

touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

sed -i -e 's%^PermitRootLogin.*%PermitRootLogin without-password%' /etc/ssh/sshd_config
sed -i -e 's%^PasswordAuthentication.*%PasswordAuthentication no%' /etc/ssh/sshd_config

cat <<'EOF' >> /etc/sysding.conf
setup_interface PRIMARY v4 dhcp
setup_ns_dns "ec2.internal" "ec2.internal" "1.1.1.1 80.80.80.80"
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
HOSTNAME=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/local-hostname`
hostname $HOSTNAME && echo $HOSTNAME >/etc/nodename
for PUBLIC_KEY in `curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-keys/`; do
  curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key >> /root/.ssh/authorized_keys
done
EOF

svccfg -s svc:/system/sysding:system setprop config/finished=false
svcadm refresh svc:/system/sysding:system

touch /reconfigure