#!/usr/bin/env bash
# Usage batchGrep.sh <input file to match in> <RegExp pattern file> [additional grep parameters]

if [ ! -s "$1" ]
then
  echo "First parameter should contain the name of the input file!" >/dev/stderr
  exit 1
fi
if [ ! -s "$2" ]
then
  echo "Second parameter should contain the name of the file containing the regexps (one per line)!" >/dev/stderr
  exit 1
fi


LONGESTLINE=$(awk 'length > max_length { max_length = length } END { print max_length}' $2)
LONGESTARG=$(getconf ARG_MAX)    # Get argument limit in bytes
BATCHSIZE=$(( (LONGESTARG - 10) / LONGESTLINE ))
echo "Safe batch size: (Argument length limit: $LONGESTARG - 10) / Longest line: $LONGESTLINE = $BATCHSIZE batch size" >/dev/stderr

LINECOUNTER=0
GREPCMD="grep -E $3 \""

# Need to avoid piping the loop, not to make bash create a subshell, because if it did, we could not retain the last grep command outside the loop.
while read
do
  if [ $((++LINECOUNTER % BATCHSIZE)) -eq "0" ]
  then
	GREPCMD="$GREPCMD$REPLY\$\""
	eval $GREPCMD $1
	GREPCMD="grep -E $3 \""
  else
    GREPCMD="$GREPCMD$REPLY|"
  fi
done < $2
eval $GREPCMD FinalNotFindbleClosingPattern\" $1
