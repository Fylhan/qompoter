#!/usr/bin/env bash

fails=0
i=0
offline=$1
tests=`ls show/*${offline}.json | wc -l`
echo "1..${tests##* }"
for input in show/*${offline}.json
do
  i=$((i+1))
  if ! ../qompoter.sh show --no-color --file "$input" | diff -u - "${input%.json}.expected"
  then
    echo "not ok $i - $input - error during show"
    fails=$((fails+1))
  else
    echo "ok $i - $input"    
  fi
done
#~ echo "$fails test(s) failed"
exit $fails
