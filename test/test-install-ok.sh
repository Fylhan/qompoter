#!/bin/sh

cd ${0%/*}
fails=0
i=0
tests=`ls install-ok/*.json | wc -l`
echo "1..${tests##* }"
for input in install-ok/*.json
do
  i=$((i+1))
  if ! ../qompoter.sh install --no-color --qompoter-file "$input" --repo qompoter-repo | diff -u - "${input%.json}.expected" \
    || ! find vendor -maxdepth 4 | grep -v ".git" | diff -u - "${input%.json}.vendor.expected"
  then
    echo "not ok $i - $input"
    fails=$((fails+1))
  else
    echo "ok $i - $input"    
  fi
  rm -rf vendor
done
#~ echo "$fails test(s) failed"
exit $fails