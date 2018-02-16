#!/bin/bash
#
# 04-17-2018 - A.W.M. Koks
# tkoks@n271.net
# Check for available updates Debian OS
#
ZBX_DATA=/tmp/debian_check_updates.data
HOSTNAME=$(egrep ^Hostname= /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
ZBX_SERVER_IP=$(egrep ^ServerActive /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
RELEASE=$(lsb_release -d | cut -d : -f 2 | cut -d $'\t' -f 2)
STATUS=$(/usr/sbin/ufw status | grep "Status:" | cut -d: -f 2 | cut -d ' ' -f 2)

### Check if zabbix-sender is installed ###
if ! dpkg-query -l zabbix-sender 2> /dev/null | grep ^ii > /dev/null; then
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

### Available updates ###
apt-get -q=2 update
UPDATES=$(apt-get --dry-run --show-upgraded upgrade | grep "^Inst" | wc -l)
SECURITY=$(apt-get --dry-run --show-upgraded upgrade | grep "^Inst" | grep -security | wc -l)

### Check if Firewall is running ###
if [[ "$STATUS" == "active" ]]
then
  FIREWALL=1
else
  FIREWALL=0
fi

echo -n > $ZBX_DATA
echo \"$HOSTNAME\" debian.release $RELEASE >> $ZBX_DATA
echo \"$HOSTNAME\" debian.updates $UPDATES >> $ZBX_DATA
echo \"$HOSTNAME\" debian.securityupdates $SECURITY >> $ZBX_DATA
echo \"$HOSTNAME\" debian.firewall $FIREWALL >> $ZBX_DATA

zabbix_sender -z $ZBX_SERVER_IP -i $ZBX_DATA &> /dev/null
