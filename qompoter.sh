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
  echo "  done"
  echo
}

repositoryPath=P:

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

echo 'Qompoter'
echo '========'
echo

projectPath='PlateformeVehiculeElectrique/4_workspace/qompoter'
repositoryPath=${repositoryPath}/${projectPath}
# Prepare vendor
vendorDir=${PWD}/vendor
mkdir -p ${vendorDir}
echo 'include($$PWD/../common.pri)' > ${vendorDir}/vendor.pri
echo '$$setLibPath()' >> ${vendorDir}/vendor.pri
cat qompoter.config | while read line; do
    downloadRequire $repositoryPath $line
done
