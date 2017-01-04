#!/usr/bin/env bash

fails=0
i=0
offline=$1
tests=`ls require/*${offline}.json | wc -l`
echo "1..${tests##* }"
for input in require/*${offline}.json
do
  i=$((i+1))
  if ! ../qompoter.sh require --list --no-color --file "$input" | diff -u - "${input%.json}.expected"
  then
    echo "not ok $i - $input - error during require"
    fails=$((fails+1))
  else
    echo "ok $i - $input"    
  fi
done
#~ echo "$fails test(s) failed"
exit $fails