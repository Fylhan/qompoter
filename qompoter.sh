#!/bin/bash

usage()
{
  echo "usage: $0 [ --repo <repo> | --help ]"
  echo ""
  echo " --repo		Distant Repository to use."
  echo " --help		Display this help."
  echo ""
  echo "Example: $0 --repo /Project"
}

downloadRequire()
{
  repositoryPath=$1
  requireVendor=$2
  requireName=$3
  requireVersion=$4
  isSource=$5

  vendorDir=${PWD}/vendor
  mkdir -p ${vendorDir}

  echo "* ${requireVendor}/${requireName} ${requireVersion}"
  requirePath=${repositoryPath}/${requireVendor}/${requireName}/${requireVersion}
  mkdir -p ${vendorDir}/${requireName}
  if [ "$isSource" = "1" ]; then
    cp -rf ${requirePath}/* ${vendorDir}/${requireName}
  else
    cp -rf ${requirePath}/lib_* ${vendorDir}
    cp -rf ${requirePath}/include ${vendorDir}/${requireName}
  fi
  cat ${requirePath}/qompoter.pri >> ${vendorDir}/vendor.pri
#  requireBasePath=${repositoryPath}/${requireVendor}/${requireName}
 # requirePath=${requireBasePath}/${requireVersion}
  #requireLocalPath=${vendorDir}/${requireVendor}/${requireName}
  #mkdir -p ${vendorDir}/${requireName}
 # if [ "$isSource" == "1" ]; then
#	if [ -d "$requireBasePath.git" ]; then
#		git clone -b v${requireVersion} ${requireBasePath}.git
#		cat ${requireLocalPath}/qompoter.pri >> ${vendorDir}/vendor.pri
#	else
#		cp -rf ${requirePath}/src/* ${vendorDir}/${requireName}
#		cat ${requireLocalPath}/qompoter.pri >> ${vendorDir}/vendor.pri
#	fi
 # else
#	cp -rf ${requirePath}/lib/lib_* ${vendorDir}
#	cp -rf ${requirePath}/lib/include ${vendorDir}/${requireName}
##	cat ${requireLocalPath}/qompoter.pri >> ${vendorDir}/vendor.pri
  #fi
  echo "  done"
  echo
}

if [ "$#" != 2 ]; then
  echo "Not enough parameter"
  usage
  exit -1
fi

while [ "$1" != "" ]; do
case $1 in
  -r | --repo )
    shift
    repositoryPath=$1
    shift
    ;;
  -d | --dest )
    shift
    destPath=$1
    shift
    ;;
  -h | --help )
    usage
    exit 0
    ;;
  *)
    echo "Unknown parameter $1"
    usage
    exit -1
    ;;
esac
done

#
# However processing JSON from untrustworthy sources still can confuse your script!
# YOU HAVE BEEN WARNED!
 
# Following needs bash. Use like in:
# eval "$(json2bash <<<"$JSONDATA")"
# JSONDATA must be coming from a trustworthy source, else harm may arise!
json2bash()
{
# This only supports a single array output, as multidimensional arrays are not supported
# -MJSON needs libjson-perl under Debian
# STDIN must be from a trustworthy source!
perl -MJSON -0777 -n -E 'sub J {
my ($p,$v) = @_; my $r = ref $v;
if ($r eq "HASH") { J("${p}_$_", $v->{$_}) for keys %$v; }
elsif ($r eq "ARRAY") { $n = 0; J("$p"."[".$n++."]", $_) foreach @$v; }
else { $v =~ '"s/'/'\\\\''/g"'; $p =~ s/^([^[]*)\[([0-9]*)\](.+)$/$1$3\[$2\]/;
$p =~ tr/-/_/; $p =~ tr/A-Za-z0-9_[]//cd; say "$p='\''$v'\'';"; }
}; J("json", decode_json($_));'
} 

echo 'Qompoter'
echo '========'
echo

projectPath='PlateformeVehiculeElectrique/4_workspace/qompoter'
projectPath='Eco2Charge/Code/vendor/'
repositoryPath=${repositoryPath}/${projectPath}
dest='.'
# Prepare vendor
mkdir -p ${dest}/vendor
echo 'include($$PWD/../common.pri)' > ${dest}/vendor/vendor.pri
echo '$$setLibPath()' >> ${dest}/vendor/vendor.pri

#awk -F';' '{ system("./downloadRequire.sh $1 $2 $3 $4") }' qompoter.csv
#xargs -a qompoter2.csv -d ';' ./downloadRequire.sh
#cat qompoter2.csv | xargs ./downloadRequire.sh 
#cat qompoter.csv | awk -F';' '{ print $1 $2 $3 $4 }'
cat qompoter.config | while read line; do
    downloadRequire $repositoryPath $line
done

#cat qompoter.json | json2bash
