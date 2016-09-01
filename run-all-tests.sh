#!/usr/bin/env bash

cd test
set -e
fail=0
tests=0
echo -e "\e[1mQompoter Test Suite\e[0m"
echo "###################"

suffix=""
while [ "$1" != "" ]; do
  case $1 in
    --offline )
      suffix="-offline"
      shift
      ;;
  esac
done

echo $suffix

for test in *.sh ;
do
  tests=$((tests+1))
  echo -e "\e[1mTEST\e[0m: $test"
  ./$test ${suffix} && ret=0 || ret=$?
  if [ $ret -eq 0 ] ; then
    echo -e "\e[1;32mOK\e[0m:   $test"
    passed=$((passed+1))
  else
    echo -e "\e[1;31mFAIL\e[0m: $test $fail"
    fail=$((fail+ret))
  fi
  echo
done

if [ $fail -eq 0 ]; then
  echo -e -n '\e[1;32mSUCCESS\e[0m '
  exitcode=0
else
  echo -e -n '\e[1;31mFAILURE\e[0m '
  exitcode=1
fi
echo "$passed / $tests"
exit $exitcode