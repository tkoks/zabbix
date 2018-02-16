#! /bin/bash
#
# 04-17-2017 - A.W.M. Koks
# tkoks@n271.net
# number of days until certificate expires to standard output
#
SERVER=$1
PORT=$2

if [[ $# -lt 2 ]]
then
  echo "Usage: $0 url port"
  exit 1
fi

END_DATE=$(openssl s_client -connect "$SERVER:$PORT" </dev/null 2>/dev/null | \
openssl x509 -noout -dates 2>/dev/null | grep notAfter | cut -d'=' -f2)

if [[ $END_DATE == "" ]]; then
  echo "No certificate found!"
  exit 1
else
  END_DATE=$(date -d "$END_DATE" +%s)
  DATE=$(date +%s)
  VALID_DAYS_REMAINING=$(((END_DATE-DATE)/3600/24))
fi

echo ${VALID_DAYS_REMAINING}
