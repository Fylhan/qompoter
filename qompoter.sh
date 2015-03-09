#!/bin/bash

usage()
{
  echo "usage: $0 [ --repo <repo> | --help ]"
  echo ""
  echo " --repo		Distant Repository to use."
  echo " --no-dev	Don't retrieve dev dependencies."
  echo " --help		Display this help."
  echo ""
  echo "Example: $0 --repo /Project"
}

downloadRequire()
{
  repositoryPath=$1
  vendorDir=$2
  requireVendor=$3
  requireName=$4
  requireVersion=$5
  isSource=$6

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

if [ "$#" < 2 ]; then
  echo "Not enough parameter"
  usage
  exit -1
fi

dev=(-dev)?
while [ "$1" != "" ]; do
case $1 in
  -r | --repo )
    shift
    repositoryPath=$1
    shift
    ;;
  --no-dev )
    dev=
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

echo 'Qompoter'
echo '========'
echo

projectPath='PlateformeVehiculeElectrique/4_workspace/qompoter'
repositoryPath=${repositoryPath}/${projectPath}
vendorDir=${PWD}/vendor
mkdir -p ${vendorDir}
echo 'include($$PWD/../common.pri)' > ${vendorDir}/vendor.pri
echo '$$setLibPath()' >> ${vendorDir}/vendor.pri

#cat qompoter.config | while read line; do
#    downloadRequire $repositoryPath $vendorDir $line
#done

cat qompoter.json | JSON.sh | egrep "\[\"require${dev}\",\".*\"\]" | sed -r "s/\"//g;s/\// /g;s/\[require${dev},//g;s/\]	/ /g;s/-lib/ 0/g" | while read line; do
    downloadRequire $repositoryPath $vendorDir $line 1
done