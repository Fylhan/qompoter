#!/usr/bin/env bash

TEST_NAME="install-git"
FAILS=0
i=0
QOMPOTER_FILE='manual-test-install-git-qompoter.json'
qompoterBranch='{ "name": "install-git/git", "require": { "trialog/solilog": "dev-tcanp" }}'
qompoterVersion='{ "name": "install-git/git", "require": { "trialog/solilog": "v1.0" }}'
qompoterVersionStar='{ "name": "install-git/git", "require": { "trialog/solilog": "v1.*" }}'
qompoterCommit='{ "name": "install-git/git", "require": { "trialog/solilog": "#29a6944" }}'
QOMPOTER_FILES=("${qompoterBranch}" "${qompoterVersion}" "${qompoterVersionStar}" "${qompoterCommit}")
EXPECTED_RESULTS=("tcanp" "v1.1-alpha" "v1.0" "29a6944")

echo "1..$((${#QOMPOTER_FILES[*]}+3))"

function checkVersion()
{
  local i=$1
  local testCase=$2
  local pattern=$3
  
  if [ "$?" == "0" ]; then
    cd vendor/solilog
    local res=`git status | grep "${pattern}"`
    if [ ! -z "${res}" ]; then
      cd ../..
      echo "ok ${i} - ${testCase}"
      return 0
    fi
    cd ../..
  fi
  echo "not ok ${i} - ${TEST_CASE}"
  FAILS=$((FAILS+1))
  return 1
}

i=$((i+1))
TEST_CASE="install a git package at a given branch"
echo $qompoterBranch > $QOMPOTER_FILE
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --repo ../../qompoter-repo > 1
checkVersion "${i}" "${TEST_CASE}" "tcanp"

i=$((i+1))
TEST_CASE="install a git package at a given soft version"
echo $qompoterVersionStar > $QOMPOTER_FILE
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --repo ../../qompoter-repo > 1
checkVersion "${i}" "${TEST_CASE}" "v1.1-alpha"

i=$((i+1))
TEST_CASE="install a git package at a given version"
echo $qompoterVersion > $QOMPOTER_FILE
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --repo ../../qompoter-repo > 1
checkVersion "${i}" "${TEST_CASE}" "v1.0"

i=$((i+1))
TEST_CASE="install a git package at a given commit number"
echo $qompoterCommit > $QOMPOTER_FILE
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --repo ../../qompoter-repo > 1
checkVersion "${i}" "${TEST_CASE}" "29a6944"

i=$((i+1))
TEST_CASE="cannot install a git package due to existing change"
echo "whatever" >> vendor/solilog/qompoter.json
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --repo ../../qompoter-repo > 1
if [ "$?" != "0" ]; then
  cd vendor/solilog
  res=`git status | grep "29a6944"`
  if [ ! -z "${res}" ]; then
    res=`git status -sb | grep "M qompoter.json"`
    if [ ! -z "${res}" ]; then
      cd ../..
      echo "ok ${i} - ${TEST_CASE}"
    else
      cd ../..
      echo "not ok ${i} - ${TEST_CASE}"
    fi
  else
    cd ../..
    echo "not ok ${i} - ${TEST_CASE}"
  fi
else
  echo "not ok ${i} - ${TEST_CASE}"
fi

i=$((i+1))
TEST_CASE="install a git package by forcing overriding existing change"
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --repo ../../qompoter-repo --force > 1
if [ "$?" == "0" ]; then
  cd vendor/solilog
  res=`git status | grep "29a6944"`
  if [ ! -z "${res}" ]; then
    res=`git status -sb | grep "M qompoter.json"`
    if [ -z "${res}" ]; then
      cd ../..
      echo "ok ${i} - ${TEST_CASE}"
    else
      cd ../..
      echo "not ok ${i} - ${TEST_CASE}"
    fi
  else
    cd ../..
    echo "not ok ${i} - ${TEST_CASE}"
  fi
else
  echo "not ok ${i} - ${TEST_CASE}"
fi

i=$((i+1))
TEST_CASE="install a git package at a given soft version stable only"
echo $qompoterVersionStar > $QOMPOTER_FILE
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --stable-only --repo ../../qompoter-repo > 1
checkVersion "${i}" "${TEST_CASE}" "v1.1"

rm 1
rm $QOMPOTER_FILE
rm qompoter.log
rm -rf vendor
exit $FAILS
