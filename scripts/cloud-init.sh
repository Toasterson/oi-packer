#!/usr/bin/bash
set -ex

pkg install -v gcc-7 system/header

wget https://github.com/omniosorg/cloud-init/archive/refs/tags/illumos-21.3.tar.gz
gtar -xzf illumos-21.3.tar.gz

cd cloud-init-illumos-21.3/

python3 -mpip install -U -r requirements.txt

python3 setup.py install --init-system=smf

rm -rf cloud-init-illumos-21.3/ illumos-21.3.tar.gz

#curl http://$PACKER_HTTP_ADDR/userscript/userscript.sh > /usr/lib/userscript.sh
#curl http://$PACKER_HTTP_ADDR/userscript/userscript.xml > /lib/svc/manifest/system/userscript.xml
#chmod +x /usr/lib/userscript.sh

#svccfg import /lib/svc/manifest/system/userscript.xml

#mkdir -p /var/metadata/
#curl http://$PACKER_HTTP_ADDR/userscript/init_fallback_with_dhcp.sh > /var/metadata/userscript
#chmod +x /var/metadata/userscript

# Setup OS to run console con COM0
cat <<EOF > /boot/conf.d/cloud-init-serial.conf
console="ttya"
autoboot_delay="-1"
EOF
