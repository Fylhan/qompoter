#!/usr/bin/env bash

name="install-ok"
fails=0
i=0
tests=`ls ${name}/*.json | wc -l`
echo "1..${tests##* }"
for input in ${name}/*.json
do
  i=$((i+1))
  pwd
  if ! ../qompoter.sh install --verbose --no-color --qompoter-file "$input" --repo qompoter-repo | diff -u - "${input%.json}.expected" \
    || ! find vendor -maxdepth 4 | grep -v ".git" | diff -u - "${input%.json}.vendor.expected"
  then
    cat qompoter.log
    echo "not ok $i - $input"
    fails=$((fails+1))
  else
    echo "ok $i - $input"    
  fi
  rm -rf vendor
done
#~ echo "$fails test(s) failed"
exit $fails