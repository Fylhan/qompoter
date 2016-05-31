#!/bin/sh

cd ${0%/*}
fails=0
i=0
tests=`ls install-nok/*.json | wc -l`
echo "1..${tests##* }"
for input in install-nok/*.json
do
  expected="${input%.json}.expected"
  i=$((i+1))
  if ! ../qompoter.sh install --no-color --qompoter-file "$input" --repo qompoter-repo | diff -u - "$expected"  \
    || ! find vendor -maxdepth 4 | grep -v ".git" | diff -u - "${input%.json}.vendor.expected"
  then
    echo "not ok $i - $input"
    fails=$((fails+1))
  else
    echo "ok $i - $input"    
  fi
  rm -rf vendor
  rm qompoter.log
done
#~ echo "$fails test(s) failed"
exit $fails