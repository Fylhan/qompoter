#!/usr/bin/env bash

fails=0
i=0
tests=`ls require/*.json | wc -l`
echo "1..${tests##* }"
for input in require/*.json
do
  i=$((i+1))
  if ! ../qompoter.sh require --list --no-color --qompoter-file "$input" | diff -u - "${input%.json}.expected"
  then
    echo "not ok $i - $input - error during require"
    fails=$((fails+1))
  else
    echo "ok $i - $input"    
  fi
done
#~ echo "$fails test(s) failed"
exit $fails