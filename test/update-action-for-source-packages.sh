#!/usr/bin/env bash

name="update"
fails=0
i=0
offline=$1
tests=$(ls ${name}/*${offline}.json | wc -l)
echo "1..${tests##* }"

echo "Create fake Git repository"
REPO=qompoter-repo
mkdir "${REPO}/git"
mkdir "${REPO}/git/acme-git"
mkdir "${REPO}/git/acme-git/tmp"
cd "${REPO}/git/acme-git/tmp"
touch qompoter.pri
git init
git add qompoter.pri
git commit -m "First commit"
git tag v2.0.2
touch another-file.txt
git add another-file.txt
git commit -m "Second commit"
git tag v2.0.3
cd ..
git clone --bare tmp acme-git.git
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
rm update/but-update-because-no-lock-file-offline.lock
rm -rf "${REPO}/git"
#~ echo "$fails test(s) failed"
exit $fails
