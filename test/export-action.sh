#!/usr/bin/env bash

fails=0
i=0
offline=$1
tests=$(ls require/*"${offline}".json | wc -l)
echo "1..${tests##* }"
for input in require/*${offline}.json
do
  i=$((i+1))
  mkdir vendor
  mkdir vendor/test
  touch vendor/qompote.pri
  touch vendor/vendor.pri
  input_file_name=$(echo "$input" | cut -d'/' -f2 | cut -d'.' -f1)
  if ! ../qompoter.sh export --no-color --file "$input" > /dev/null 2>&1
  then
    echo "not ok $i - $input - error during export"
    fails=$((fails+1))
  else
    if [ ! -f "$(date +"%Y-%m-%d")_${input_file_name}_vendor.zip" ]; then
      echo "error: no archive \"$(date +"%Y-%m-%d")_${input_file_name}_vendor.zip\""
      echo "not ok $i - $(echo "$input" | tr '-' ' ' | sed 's/.json//' | sed 's/ offline//')"
      fails=$((fails+1))
    else
      echo "ok $i - $(echo "$input" | tr '-' ' ' | sed 's/.json//' | sed 's/ offline//')"
      rm "$(date +"%Y-%m-%d")_${input_file_name}_vendor.zip"
    fi
  fi
  rm -rf vendor
done
#~ echo "$fails test(s) failed"
exit $fails
