#!/bin/bash
set -e -u -o pipefail

SOURCE=$1
LINES_PER_FILE=100000
LINES_IN_SOURCE=$(wc -l $SOURCE  | cut -f1 -d' ')
ITERATIONS=$(echo "($LINES_IN_SOURCE/$LINES_PER_FILE)" | bc)
INSERT_STATEMENT=$(grep INSERT $SOURCE)


rm -f ${SOURCE}_* postgis.sql postgis.sql.gz

for i in $(seq 0 $ITERATIONS) ; do
  START=$(echo $LINES_PER_FILE*$i+1 | bc)
  STOP=$(echo "$START-1+$LINES_PER_FILE" | bc)
  IT_TARGET=${SOURCE}_$i
  if [ $i -gt 0 ] ; then
    echo $INSERT_STATEMENT > $IT_TARGET
  fi
  sed -n "$START,${STOP}p" $SOURCE >> $IT_TARGET
  sed -i '$ s/,$/;/g' $IT_TARGET
done

cat ${SOURCE}_* > postgis.sql

gzip postgis.sql
rm -rf ${SOURCE} ${SOURCE}_* postgis.sql
