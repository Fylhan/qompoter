#!/usr/bin/env bash

name="update"
fails=0
i=0
offline=$1
tests=$(ls ${name}/*${offline}.json | wc -l)
echo "1..${tests##* }"

echo "preamble: Create fake Git repository"
REPO=qompoter-repo
mkdir "${REPO}/git"
mkdir "${REPO}/git/acme-git"
mkdir "${REPO}/git/acme-git/tmp"
cd "${REPO}/git/acme-git/tmp"
touch qompoter.pri
git init &> /dev/null
git add qompoter.pri &> /dev/null
git commit -m "First commit" &> /dev/null
git tag v2.0.2 &> /dev/null
touch another-file.txt
git add another-file.txt &> /dev/null
git commit -m "Second commit" &> /dev/null
git tag v2.0.3 &> /dev/null
cd ..
git clone --bare tmp acme-git.git &> /dev/null
rm -rf tmp
cd ../../../

for input in ${name}/*${offline}.json
do
  i=$((i+1))
  if ! ../qompoter.sh update --no-color --file "$input" --repo qompoter-repo | diff -u - "${input%.json}.expected" \
    || ! find vendor -maxdepth 4 | grep -v ".git" | LC_ALL=C sort | diff -u - "${input%.json}.vendor.expected"
  then
    echo "not ok $i - $(echo $input | tr '-' ' ' | sed 's/.json//' | sed 's/ offline//')"
    fails=$((fails+1))
  else
    echo "ok $i - $(echo $input | tr '-' ' ' | sed 's/.json//' | sed 's/ offline//')"
  fi
  rm -rf vendor
done
echo "postamble: Remove lock file for 'but-update-because-no-lock-file-offline.json'"
rm update/but-update-because-no-lock-file-offline.lock
echo "postamble: Remove fake Git repository"
rm -rf "${REPO}/git"
#~ echo "$fails test(s) failed"
exit $fails
