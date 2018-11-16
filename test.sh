#!/bin/bash

source rip.cfg

echo "DT: $DATETIME"
echo "DISC: ${DISC} / ${DISCS}"

if [ $DISCS -gt 1 ] && [ $DISC -le $DISCS ]; then
	DISCNUMBER=$DISC
	echo "DISC=$((DISC+1))" >> rip.cfg
else
	DISCNUMBER="0"
fi

if [[ "$DISCNUMBER" == "0" ]]; then
 	echo "ripping single cd"
else
 	echo "ripping cd $DISCNUMBER --> abcde ... -W $DISCNUMBER'"
fi

