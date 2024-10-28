#!/usr/bin/bash -x
sed -i "s/ListenAddress ::/#ListenAddress ::/g" /etc/ssh/sshd_config

pkg update -v

reboot
