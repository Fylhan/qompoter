#!/usr/bin/env bash

fails=0
i=0
offline=$1
tests=`ls install-ok/*${offline}.json | wc -l`
echo "1..${tests##* }"
for input in install-ok/*${offline}.json
do
  i=$((i+1))
  mkdir vendor
  mkdir vendor/test
  touch vendor/qompote.pri
  touch vendor/vendor.pri
  if ! ../qompoter.sh export --no-color --file "$input" > /dev/null 2>&1
  then
    echo "not ok $i - $input - error during export"
    fails=$((fails+1))
  else
    if [ ! -f "`date +"%Y-%m-%d"`_install-ok_vendor.zip" ]; then
      echo "not ok $i - $input - no archive"
      fails=$((fails+1))
    else
      echo "ok $i - $input"    
      rm "`date +"%Y-%m-%d"`_install-ok_vendor.zip"
    fi
  fi
  rm -rf vendor
done
#~ echo "$fails test(s) failed"
exit $fails