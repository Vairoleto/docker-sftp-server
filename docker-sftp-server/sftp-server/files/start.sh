#!/bin/sh
 if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa -b 2048
 fi
 if [ ! -f /etc/ssh/iptables.rules.v4 ]; then
        touch /etc/ssh/iptables.rules.v4
 fi
iptables-restore /etc/ssh/iptables.rules.v4
/usr/sbin/rsyslogd -n
/usr/sbin/sshd -D -e