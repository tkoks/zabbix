#!/bin/bash
#
# 04-14-2017 - A.W.M. Koks
# tkoks@n271.net
# send xmpp notification
# requirement: sendxmpp from epel repo
#
SENDTO=$1
SUBJECT=$2
MESSAGE=$3

if [ $# -ne 3 ]; then
   echo "Usage: $0 sendto subject message"
   exit 1;
fi

echo -e "${SUBJECT}\n${MESSAGE}\n" | sendxmpp -f /etc/sendxmpp.conf -t $SENDTO 2> /dev/null
