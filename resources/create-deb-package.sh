#!/bin/bash

VERSION=$1
   
DEBIAN="qompoter_v"$VERSION"/DEBIAN"
SOFTDIR="qompoter_v"$VERSION"/usr/local/bin"

mkdir -p $DEBIAN
mkdir -p $SOFTDIR

wget https://github.com/Fylhan/qompoter/releases/download/v$VERSION/qompoter.sh -O qompoter.sh && sudo chmod a+x qompoter.sh && mv qompoter.sh $SOFTDIR/qompoter

##Creating control file
printf "Package: qompoter
Version: "$VERSION"
Section: base
Priority: optional
Architecture: all
Depends: bash,git,sed
Maintainer: Fylhan <fylhan@hotmail.com>
Description: Dependency manager for Qt / C++
Homepage: https://fylhan.github.io/qompoter/
" > $DEBIAN"/control"

printf "#!/bin/bash
wget https://github.com/Fylhan/qompoter/releases/download/v"$VERSION"/qompoter_bash_completion.sh -O qompoter_bash_completion.sh && sudo chmod a+x qompoter_bash_completion.sh && sudo mv qompoter_bash_completion.sh /usr/share/bash-completion/completions/qompoter
echo source /usr/share/bash-completion/completions/qompoter >> ~/.bashrc" > $DEBIAN"/postinst"

printf "#!/bin/bash
rm -f /usr/share/bash-completion/completions/qompoter" > $DEBIAN"/prerm"

chmod 775 $DEBIAN"/postinst"
chmod 775 $DEBIAN"/prerm"

dpkg-deb --build "qompoter_v"$VERSION

