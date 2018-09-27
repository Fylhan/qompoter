#!/usr/bin/env bash

name="install-ok"
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
    echo "not ok $i - $(echo $input | tr '-' ' ' | sed 's/.json//' | sed 's/ offline//')"
    fails=$((fails+1))
  else
    echo "ok $i - $(echo $input | tr '-' ' ' | sed 's/.json//' | sed 's/ offline//')"
  fi
  rm -rf vendor
done
#~ echo "$fails test(s) failed"
echo "postamble: Remove lock files"
rm ${name}/*.lock
exit $fails
