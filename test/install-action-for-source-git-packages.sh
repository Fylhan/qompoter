#!/usr/bin/env bash

OFFLINE=$1
if [ "${OFFLINE}" == "-offline" ]; then
  exit 255
fi

TEST_NAME="install-git"
FAILS=0
i=0
QOMPOTER_FILE='qompoter-test4git.json'
qompoterBranch='{ "name": "install-git/git", "require": { "fylhan/qompoter-test-package4git": "dev-mybranch" }, "repositories": { "fylhan/qompoter-test-package4git": "https://github.com" }}'
qompoterVersion='{ "name": "install-git/git", "require": { "fylhan/qompoter-test-package4git": "v1.0" }, "repositories": { "fylhan/qompoter-test-package4git": "https://github.com" }}'
qompoterVersionStar='{ "name": "install-git/git", "require": { "fylhan/qompoter-test-package4git": "v1.*" }, "repositories": { "fylhan/qompoter-test-package4git": "https://github.com" }}'
qompoterVersionStarOrderNaturally='{ "name": "install-git/git", "require": { "fylhan/qompoter-test-package4git": "v2.*" }, "repositories": { "fylhan/qompoter-test-package4git": "https://github.com" }}'
qompoterCommit='{ "name": "install-git/git", "require": { "fylhan/qompoter-test-package4git": "#9504ee4" }, "repositories": { "fylhan/qompoter-test-package4git": "https://github.com" }}'
QOMPOTER_FILES=("${qompoterBranch}" "${qompoterVersionStar}" "${qompoterVersion}" "${qompoterVersionStarOrderNaturally}" "${qompoterCommit}")
TEST_CASE_NAMES=("install a git package with given branch" \
                "install a git package with a given variadic version v1.* -> v1.1" \
                "install a git package with a given version" \
                "install a git package with a given variadic version v2.* -> v2.0.10 (whereas v2.0.1 exists)" \
                "install a git package with a given commit number")
TEST_CASE_EXPECTED_RESULTS=("mybranch" "v1.1" "v1.0" "v2.0.10" "9504ee4")

echo "1..$((${#QOMPOTER_FILES[*]}+3))"

function checkVersion()
{
  local i=$1
  local testCase=$2
  local pattern=$3

  if [ "$?" == "0" ]; then
    if [ ! -d "vendor/qompoter-test-package4git" ]; then
      echo "not ok ${i} - ${testCase} (no directory)"
      FAILS=$((FAILS+1))
      return 1
    fi
    cd vendor/qompoter-test-package4git
    local res=`git status | grep "${pattern}"`
    if [ ! -z "${res}" ]; then
      cd ../..
      echo "ok ${i} - ${testCase}"
      return 0
    fi
    cd ../..
  fi
  echo "not ok ${i} - ${testCase}"
  FAILS=$((FAILS+1))
  return 1
}

for qompoterFileData in "${QOMPOTER_FILES[@]}"; do
  echo $qompoterFileData > $QOMPOTER_FILE
  test -f "${QOMPOTER_FILE/.json/.lock}" && rm "${QOMPOTER_FILE/.json/.lock}"
  j=0
  # install and create lock
  ../qompoter.sh install --no-color --file "$QOMPOTER_FILE" > /dev/null 2>&1
  j=$((j+1))
  checkVersion "$((i+1)).${j}" "${TEST_CASE_NAMES[$i]}" "${TEST_CASE_EXPECTED_RESULTS[$i]}"
  # install using lock
  ../qompoter.sh install --no-color --file "$QOMPOTER_FILE" > /dev/null 2>&1
  j=$((j+1))
  checkVersion "$((i+1)).${j}" "${TEST_CASE_NAMES[$i]}" "${TEST_CASE_EXPECTED_RESULTS[$i]}"
  # update to recreate lock
  ../qompoter.sh update --no-color --file "$QOMPOTER_FILE" > /dev/null 2>&1
  j=$((j+1))
  checkVersion "$((i+1)).${j}" "${TEST_CASE_NAMES[$i]/install/update}" "${TEST_CASE_EXPECTED_RESULTS[$i]}"
  rm "${QOMPOTER_FILE/.json/.lock}"
  i=$((i+1))
done

i=$((i+1))
TEST_CASE="cannot install a git package due to existing change"
echo "whatever" >> vendor/qompoter-test-package4git/changelogs.md
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" > /dev/null 2>&1
if [ "$?" != "0" ]; then
  cd vendor/qompoter-test-package4git
  res=`git status | grep "9504ee4"`
  if [ ! -z "${res}" ]; then
    res=`git status -sb | grep "M changelogs.md"`
    if [ ! -z "${res}" ]; then
      cd ../..
      echo "ok ${i} - ${TEST_CASE}"
    else
      cd ../..
      echo "not ok ${i} - ${TEST_CASE}"
      FAILS=$((FAILS+1))
    fi
  else
    cd ../..
    echo "not ok ${i} - ${TEST_CASE}"
  fi
else
  echo "not ok ${i} - ${TEST_CASE}"
  FAILS=$((FAILS+1))
fi

i=$((i+1))
TEST_CASE="install a git package but bys-pass existing change"
test -f "${QOMPOTER_FILE/.json/.lock}" && rm "${QOMPOTER_FILE/.json/.lock}"
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --by-pass > /dev/null 2>&1
if [ "$?" == "0" ]; then
  cd vendor/qompoter-test-package4git
  res=`git status | grep "9504ee4"`
  if [ ! -z "${res}" ]; then
    res=`git status -sb | grep "M changelogs.md"`
    if [ ! -z "${res}" ]; then
      cd ../..
      echo "ok ${i} - ${TEST_CASE}"
    else
      cd ../..
      echo "there is a change on changelogs.md file in the package: $(cat 1)"
      echo "not ok ${i} - ${TEST_CASE}"
    fi
  else
    cd ../..
    echo "the expected commit number is not #9504ee4 for the package: $(cat 1)"
    echo "not ok ${i} - ${TEST_CASE}"
    FAILS=$((FAILS+1))
  fi
else
  echo "qompoter install has failed: $(cat 1)"
  echo "not ok ${i} - ${TEST_CASE}"
  FAILS=$((FAILS+1))
fi

i=$((i+1))
TEST_CASE="install a git package by forcing overriding existing change"
test -f "${QOMPOTER_FILE/.json/.lock}" && rm "${QOMPOTER_FILE/.json/.lock}"
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --force > /dev/null 2>&1
if [ "$?" == "0" ]; then
  cd vendor/qompoter-test-package4git
  res=`git status | grep "9504ee4"`
  if [ ! -z "${res}" ]; then
    res=`git status -sb | grep "M changelogs.md"`
    if [ -z "${res}" ]; then
      cd ../..
      echo "ok ${i} - ${TEST_CASE}"
    else
      cd ../..
      echo "not ok ${i} - ${TEST_CASE}"
      FAILS=$((FAILS+1))
    fi
  else
    cd ../..
    echo "not ok ${i} - ${TEST_CASE}"
  fi
else
  echo "not ok ${i} - ${TEST_CASE}"
  FAILS=$((FAILS+1))
fi

i=$((i+1))
TEST_CASE="install a git package at a given soft version stable only"
test -f "${QOMPOTER_FILE/.json/.lock}" && rm "${QOMPOTER_FILE/.json/.lock}"
echo $qompoterVersionStar > $QOMPOTER_FILE
../qompoter.sh install --no-color --file "$QOMPOTER_FILE" --stable-only > /dev/null 2>&1
checkVersion "${i}" "${TEST_CASE}" "v1.1"

rm $QOMPOTER_FILE
rm -rf vendor
echo "postamble: Remove lock files"
rm -- *.lock
exit $FAILS
