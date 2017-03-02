#!/usr/bin/env bash

name="library-packages"
fails=0
i=0
offline=$1
tests=`ls ${name}/*${offline}.json | wc -l`
echo "1..${tests##* }"
for input in ${name}/*${offline}.json
do
  i=$((i+1))
  if ! ../qompoter.sh install --no-color --file "$input" --repo qompoter-repo | diff -u - "${input%.json}.expected" \
    || ! find vendor -maxdepth 4 | grep -v ".git" | LC_ALL=C sort | diff -u - "${input%.json}.vendor.expected"
  then
    echo "not ok $i - $(echo $input | tr '-' ' ' | sed 's/.json//')"
    fails=$((fails+1))
  else
    echo "ok $i - $(echo $input | tr '-' ' ' | sed 's/.json//')"
  fi
  rm -rf vendor
done
#~ echo "$fails test(s) failed"
exit $fails
