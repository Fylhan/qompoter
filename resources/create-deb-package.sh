#!/bin/bash

VERSION=$1

if [ "" == "$VERSION" ]; then
  echo "Please select a Qompoter version number"
  echo "usage: $0 0.5.1"
  exit -1
fi
   
DEBIAN="qompoter."$VERSION"/DEBIAN"
SOFTDIR="qompoter."$VERSION"/usr/local/bin"

mkdir -p $DEBIAN
mkdir -p $SOFTDIR

wget https://github.com/Fylhan/qompoter/releases/download/v$VERSION/qompoter.sh -O qompoter.sh && sudo chmod a+x qompoter.sh && mv qompoter.sh $SOFTDIR/qompoter

##Creating control file
printf "Package: qompoter
Version: $VERSION
Standards-Version: $VERSION
Section: devel
Priority: optional
Architecture: all
Depends: bash,git,sed
Author: Fylhan <fylhan@hotmail.com>
Maintainer: Fylhan <fylhan@hotmail.com>
Description: Dependency manager for Qt / C++
Homepage: https://fylhan.github.io/qompoter/
Vcs-Git: https://github.com/Fylhan/qompoter.git
" > $DEBIAN"/control"

printf "#!/bin/bash
wget https://github.com/Fylhan/qompoter/releases/download/v"$VERSION"/qompoter_bash_completion.sh -O qompoter_bash_completion.sh && sudo chmod a+x qompoter_bash_completion.sh && sudo mv qompoter_bash_completion.sh /usr/share/bash-completion/completions/qompoter
echo source /usr/share/bash-completion/completions/qompoter >> ~/.bashrc" > $DEBIAN"/postinst"

printf "#!/bin/bash
rm -f /usr/share/bash-completion/completions/qompoter" > $DEBIAN"/prerm"

chmod 775 $DEBIAN"/postinst"
chmod 775 $DEBIAN"/prerm"

dpkg-deb --build "qompoter.$VERSION"

