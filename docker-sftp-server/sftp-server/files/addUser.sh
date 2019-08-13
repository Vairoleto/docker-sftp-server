#!/bin/sh
adduser -D $1
mkdir -p /home/$1/.ssh
mkdir /home/$1/private
ssh-keygen -f /home/$1/.ssh/ssh_key -N '' -t rsa -b 2048 -C $1@remote
cat /home/$1/.ssh/ssh_key.pub >> /home/$1/.ssh/authorized_keys 
chown -R $1:$1 /home/$1
chown root:root /home/$1
chmod -R 700 /home/$1/.ssh
chmod 600 /home/$1/.ssh/authorized_keys
sed -i s/$1:!/"$1:*"/g /etc/shadow
echo "input(type="\""imuxsock"\"" Socket="\""/home/$1/dev/log"\"" CreatePath="\""on"\"")" >> /etc/rsyslog.conf