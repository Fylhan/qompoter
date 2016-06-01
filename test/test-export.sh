#!/usr/bin/env bash

fails=0
i=0
tests=`ls install-ok/*.json | wc -l`
echo "1..${tests##* }"
for input in install-ok/*.json
do
  i=$((i+1))
  if ! ../qompoter.sh install --no-color --qompoter-file "$input" --repo qompoter-repo | diff -u - "${input%.json}.expected" \
    || ! ../qompoter.sh export --no-color --qompoter-file "$input" > /dev/null 2>&1
  then
    echo "not ok $i - $input"
    fails=$((fails+1))
  else
    if [ ! -f "`date +"%Y-%m-%d"`_install-ok_vendor.zip" ]; then
      echo "nnot ok $i - $input"
      fails=$((fails+1))
    else
      echo "ok $i - $input"    
    fi
  fi
  rm -rf vendor
  rm "`date +"%Y-%m-%d"`_install-ok_vendor.zip"
done
#~ echo "$fails test(s) failed"
exit $fails