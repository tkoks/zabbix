#!/bin/bash
#
# 04-17-2017 - A.W.M. Koks
# tkoks@n271.net
# Check for available updates CentOS
# SELinux enabled/disabled
#
ZBX_DATA=/tmp/centos_check_updates.data
HOSTNAME=$(egrep ^Hostname= /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
ZBX_SERVER_IP=$(egrep ^ServerActive /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
RELEASE=$(cat "/etc/redhat-release")
ENFORCING=$(/usr/sbin/getenforce)
STATE=$(firewall-cmd --state 2> /dev/null)

### Check if zabbix-sender is installed ###
if ! yum -q list installed zabbix-sender 2> /dev/null | grep -qw zabbix-sender; then
    echo "zabbix-sender not available"
    exit 1;
fi

### Get hostname if not set in zabbix-agentd.conf ###
if [[ "$HOSTNAME" == "" ]]
then
    HOSTNAME=$(hostname -f)
fi

### Get Zabbix Server IP address if ServerActive is empty ###
if [[ "$ZBX_SERVER_IP" == "" ]]
then
    ZBX_SERVER_IP=$(egrep ^Server /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
fi

### Check if SELinux is active ###
if [[ "$ENFORCING" == "Enforcing" ]]
then
  SELINUX=1
else
  SELINUX=0
fi

### Check if Firewall is running ###
if [[ "$STATE" == "running" ]]
then
  FIREWALL=1
else
  FIREWALL=0
fi

### Available updates ###
UPDATES=$(yum -q -e 0 check-update 2> /dev/null | wc -l)

echo -n > $ZBX_DATA
echo \"$HOSTNAME\" centos.release $RELEASE >> $ZBX_DATA
echo \"$HOSTNAME\" centos.selinux $SELINUX >> $ZBX_DATA
echo \"$HOSTNAME\" centos.firewall $FIREWALL >> $ZBX_DATA
echo \"$HOSTNAME\" centos.updates $UPDATES >> $ZBX_DATA

zabbix_sender -z $ZBX_SERVER_IP -i $ZBX_DATA &> /dev/null
