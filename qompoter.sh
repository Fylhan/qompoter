#!/usr/bin/env bash

readonly C_PROGNAME=$(basename $0)
readonly C_PROGDIR=$(readlink -m $(dirname $0))
readonly C_PROGVERSION="v0.4.0-alpha"
readonly C_ARGS="$@"
C_OK="\e[1;32m"
C_FAIL="\e[1;31m"
C_INFO="\e[1;35m"
C_SKIP="\e[1;33m"
C_END="\e[0m"

C_LOG_FILENAME=qompoter.log
QOMPOTER_FILENAME=qompoter.json
INQLUDE_FILENAME=
VENDOR_DIR=vendor
REPO_PATH=git@gitlab.lan.trialog.com:
IS_ALL=0
IS_BYPASS=0
IS_FORCE=0
IS_INCLUDE_DEV=(-dev)?
IS_NO_QOMPOTE=0
IS_STABLE_ONLY=0
IS_VERBOSE=0
DEPTH_SIZE=10
DOWNLOADED_PACKAGES=
NEW_SUBPACKAGES=${QOMPOTER_FILENAME}
VENDOR_NAME=
PROJECT_NAME=
LAST_QOMPOTERLOCK_PART='  "require": {'
# Version and path of the current package
PACKAGE_VERSION=
PACKAGE_DIST_URL=

#######################
# JSON.H              #
#######################

BRIEF=0
LEAFONLY=0
PRUNE=0

throw()
{
  echo "$*" >&2
  exit 1
}

usage_jsonh() {
  echo
  echo "Usage: JSON.sh [-b] [-l] [-p] [-h]"
  echo
  echo "-p - Prune empty. Exclude fields with empty values."
  echo "-l - Leaf only. Only show leaf nodes, which stops data duplication."
  echo "-b - Brief. Combines 'Leaf only' and 'Prune empty' options."
  echo "-h - This help text."
  echo
}

parse_options() {
  set -- "$@"
  local ARGN=$#
  while [ $ARGN -ne 0 ]
  do
    case $1 in
      -h) usage
          exit 0
      ;;
      -b) BRIEF=1
          LEAFONLY=1
          PRUNE=1
      ;;
      -l) LEAFONLY=1
      ;;
      -p) PRUNE=1
      ;;
      ?*) echo "ERROR: Unknown option."
          usage_jsonh
          exit 0
      ;;
    esac
    shift 1
    ARGN=$((ARGN-1))
  done
}

awk_egrep() {
  local pattern_string=$1

  gawk '{
    while ($0) {
      start=match($0, pattern);
      token=substr($0, start, RLENGTH);
      print token;
      $0=substr($0, start+RLENGTH);
    }
  }' pattern=$pattern_string
}

tokenize()
{
  local GREP
  local ESCAPE
  local CHAR

  if echo "test string" | grep -E -ao --color=never "test" &>/dev/null
  then
    GREP='grep -E -ao --color=never'
  else
    GREP='grep -E -ao'
  fi

  if echo "test string" | grep -E -o "test" &>/dev/null
  then
    ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\]'
  else
    GREP=awk_egrep
    ESCAPE='(\\\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\\\]'
  fi

  local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
  local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  local KEYWORD='null|false|true'
  local SPACE='[[:space:]]+'

  $GREP "$STRING|$NUMBER|$KEYWORD|$SPACE|." | grep -E -v "^$SPACE$"
}

parse_array()
{
  local index=0
  local ary=''
  read -r token
  case "$token" in
    ']') ;;
    *)
      while :
      do
        parse_value "$1" "$index"
        index=$((index+1))
        ary="$ary""$value"
        read -r token
        case "$token" in
          ']') break ;;
          ',') ary="$ary," ;;
          *) throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
      ;;
  esac
  [ "$BRIEF" -eq 0 ] && value=`printf '[%s]' "$ary"` || value=
  :
}

parse_object()
{
  local key
  local obj=''
  read -r token
  case "$token" in
    '}') ;;
    *)
      while :
      do
        case "$token" in
          '"'*'"') key=$token ;;
          *) throw "EXPECTED string GOT ${token:-EOF}" ;;
        esac
        read -r token
        case "$token" in
          ':') ;;
          *) throw "EXPECTED : GOT ${token:-EOF}" ;;
        esac
        read -r token
        parse_value "$1" "$key"
        obj="$obj$key:$value"
        read -r token
        case "$token" in
          '}') break ;;
          ',') obj="$obj," ;;
          *) throw "EXPECTED , or } GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
    ;;
  esac
  [ "$BRIEF" -eq 0 ] && value=`printf '{%s}' "$obj"` || value=
  :
}

parse_value()
{
  local jpath="${1:+$1,}$2" isleaf=0 isempty=0 print=0
  case "$token" in
    '{') parse_object "$jpath" ;;
    '[') parse_array  "$jpath" ;;
    # At this point, the only valid single-character tokens are digits.
    ''|[!0-9]) throw "EXPECTED value GOT ${token:-EOF}" ;;
    *) value=$token
       isleaf=1
       [ "$value" = '""' ] && isempty=1
       ;;
  esac
  [ "$value" = '' ] && return
  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && [ $PRUNE -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 1 ] && [ "$isempty" -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && \
    [ $PRUNE -eq 1 ] && [ $isempty -eq 0 ] && print=1
  [ "$print" -eq 1 ] && printf "[%s]\t%s\n" "$jpath" "$value"
  :
}

parse()
{
  read -r token
  parse_value
  read -r token
  case "$token" in
    '') ;;
    *) throw "EXPECTED EOF GOT $token" ;;
  esac
}

jsonh()
{
  parse_options "$@"
  tokenize | parse
}



#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#                     #
#                     #
#                     #
#      QOMPOTER       #
#                     #
#                     #
#                     #
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################
#######################

usage()
{
	cat <<- EOF
	Usage: $C_PROGNAME [action] [ --repo <repo> | other options ]

	    action               Select an action:
	                          export, init, inspect, install, require

	                         Other actions are useful for digging into Qompoter:
	                          inqlude, jsonh, md5sum

	Options:

          --all             List or apply actions to all elements depending of
                            the action
                            Supported action is: inspect

	        --by-pass         By-pass error and continue the process
	                          Supported actions are: export --repo, install

	    -d, --depth SIZE      Depth of the recursivity in the searching of
	                          subpackages [default = $DEPTH_SIZE]

	    --inqlude-file FILE   Pick the provided file to search into the
	                          inqlude repository

	        --file FILE       Pick another Qompoter file [default = $QOMPOTER_FILENAME]

	    -f, --force           By-pass error by forcing the action to be taken
	                          and continue the process
	                          Supported actions are: export --repo, install

	    -l, --list            List elements depending of the action
	                          Supported action is: require

	        --minify          Minify the provided file
	                          Supported action is: inqlude

	        --no-color        Do not enable color on output [default = false]

	        --no-dev          Do not retrieve dev dependencies listed
	                          in "require-dev" [default = false]
	                          Supported action is: install

	        --no-qompote      Do not generate any Qompoter specific stuffs
	                          like qompote.pri and vendor.pri [default = false]
	                          Supported actions are: init, install

	    -r, --repo DIR        Select a repository path as a location for
	                          dependency research or export. It is used in
	                          addition of the "repositories" provided in
	                          "qompoter.json".
	                          Supported actions are: export, install

	        --search PACKAGE  Search related packages in a repository
	                          Supported action is: inqlude

	        --stable-only     Do not select unstable versions [default = false]
	                          E.g. If "v1.*" is given to Qompoter, it will select
	                          "v1.0.3" and not "v1.0.4-RC1"
	                          Supported action is: install

	        --vendor-dir DIR  Pick another vendor directory [default = $VENDOR_DIR]
	                          Supported actions are: export, inspect, install,
	                          md5sum

	    -V, --verbose         Enable more verbosity

	    -VV                   Enable really more verbosity

	    -VVV                  Enable really really more verbosity

	    -h, --help            Display this help

	    -v, --version         Display the version

	Examples:

	    Install all dependencies:
	      $C_PROGNAME install --repo ~/qompoter-repo

	    Install only nominal and stable dependencies:
	      $C_PROGNAME install --no-dev --stable-only --repo ~/qompoter-repo

	    List required dependencies for this project:
	      $C_PROGNAME require --list

	    List manually modified dependencies for this project:
	      $C_PROGNAME inspect

	    Export vendor directory:
	      $C_PROGNAME export

	    Export vendor directory as a qompotist-fs repository:
	      $C_PROGNAME export --repo ~/other-qompoter-repo

	    Search dependency in the inqlude repository:
	      $C_PROGNAME inqlude --search vogel/injeqt

	    Generate boilerplate for the "old/yoda" package starting from version 900.0
	      $C_PROGNAME init old/yoda v900.0

	EOF
}

version()
{
	cat <<- EOF
	Qompoter ${C_PROGVERSION}
	Dependency manager for C++/Qt by Fylhan
	EOF
}

createQompotePri()
{
	local qompotePri=$1
	cat << 'EOF' > "${qompotePri}"
# $$setLibPath()
# Generate a lib path name depending of the OS and the arch
# Export and return LIBPATH
defineReplace(setLibPath){
    # Detection of YoctoLinux SDK
    YOCTO = $$(TARGET_PREFIX)
    !isEmpty(YOCTO) {
      LIBPATH = $${YOCTO}lib
    }
    else {
      LIBPATH = lib
      # Windows / Linux
      win32|win32-cross-mingw {
        LIBPATH = $${LIBPATH}_windows
      }
      else:unix {
        LIBPATH = $${LIBPATH}_linux
      }
      # Precise architecture for Linux host
      linux-g++-32 {
        LIBPATH = $${LIBPATH}_32
      }
      else:linux-g++-64 {
        LIBPATH = $${LIBPATH}_64
      }
      else:linux-arm-gnueabi-g++ {
        LIBPATH = $${LIBPATH}_arm-gnueabi
      }
      # Or use architecture of the host when not provided
      else {
        contains(QMAKE_HOST.arch, x86_64) {
          LIBPATH = $${LIBPATH}_64
        }
        else {
          LIBPATH = $${LIBPATH}_32
        }
      }
    }

    export(LIBPATH)
    return($${LIBPATH})
}

# $$setLibName(lib name[, lib version])
# Will add a "d" at the end of lib name in case of debug compilation, and "-version" if provided
# Export VERSION, export and return LIBNAME
defineReplace(setLibName){
    unset(LIBNAME)
    LIBNAME = $$1
    VERSION = $$2
    CONFIG(debug,debug|release){
      LIBNAME = $${LIBNAME}d
    }

    export(VERSION)
    export(LIBNAME)
    return($${LIBNAME})
}

# $$getLibName(lib name)
# Will add a "d" at the end of lib name in case of debug compilation, and "-version" if provided
# Return lib name
defineReplace(getLibName){
    ExtLibName = $$1
    QtVersion = $$2
    equals(QtVersion, "Qt"){
      ExtLibName = $${ExtLibName}-Qt$$QT_VERSION
    }
    CONFIG(debug,debug|release){
      ExtLibName = $${ExtLibName}d
    }

    return($${ExtLibName})
}

# $$getCompleteLibName(lib name)
# Will add a "d" at the end of lib name in case of debug  echo compilation, and "-version" if provided
# Return lib name
defineReplace(getCompleteLibName){
    ExtLibName = $$1
    QtVersion = $$2
    LIBSUFIX = a
    contains(CONFIG,"dll"){
      win32|win32-cross-mingw {
        LIBSUFIX = dll
      }
      else:unix {
        LIBSUFIX = so
      }
    }
    contains(CONFIG,"shared"){
      win32|win32-cross-mingw {
        LIBSUFIX = dll
      }
      else:unix {
        LIBSUFIX = so
      }
    }
    contains(CONFIG,"static"){
      LIBSUFIX = a
    }
    return(lib$$getLibName($$ExtLibName,$$QtVersion).$$LIBSUFIX)
}

# $$setBuildDir()
# Generate a build dir depending of OS and arch
# Export MOC_DIR, OBJECTS_DIR, UI_DIR, TARGET, LIBS
defineReplace(setBuildDir){
    CONFIG(debug,debug|release){
      MOC_DIR = debug
      OBJECTS_DIR = debug
      UI_DIR      = debug
    }
    else {
      MOC_DIR = release
      OBJECTS_DIR = release
      UI_DIR      = release
    }

    # Detection of YoctoLinux SDK
    YOCTO = $$(TARGET_PREFIX)
    !isEmpty(YOCTO) {
      MOC_DIR     = $${MOC_DIR}/$${YOCTO}build
      OBJECTS_DIR = $${OBJECTS_DIR}/$${YOCTO}build
      UI_DIR      = $${UI_DIR}/$${YOCTO}build
    }
    # Windows
    else:win32|win32-cross-mingw{
      MOC_DIR     = $${MOC_DIR}/build_windows
      OBJECTS_DIR = $${OBJECTS_DIR}/build_windows
      UI_DIR      = $${UI_DIR}/build_windows
    }
    # Linux for different architecture
    else:linux-g++-32{
      MOC_DIR     = $${MOC_DIR}/build_linux_32
      OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_32
      UI_DIR      = $${UI_DIR}/build_linux_32
    	LIBS       += -L/usr/lib/gcc/i586-linux-gnu/4.9
    }
    else:linux-g++-64{
      MOC_DIR     = $${MOC_DIR}/build_linux_64
      OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_64
      UI_DIR      = $${UI_DIR}/build_linux_64
      LIBS       += -L/usr/lib/gcc/x86_64-linux-gnu/4.9
    }
    else:linux-arm-gnueabi-g++{
      MOC_DIR     = $${MOC_DIR}/build_linux_arm-gnueabi
      OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_arm-gnueabi
      UI_DIR      = $${UI_DIR}/build_linux_arm-gnueabi
      LIBS       += -L/usr/lib/gcc/arm-linux-gnueabi/4.9
    }
    # Linux use the architecture of the host
    else:unix{
      contains(QMAKE_HOST.arch, x86_64){
          MOC_DIR     = $${MOC_DIR}/build_linux_64
          OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_64
          UI_DIR      = $${UI_DIR}/build_linux_64
      }
      else{
          MOC_DIR     = $${MOC_DIR}/build_linux_32
          OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_32
          UI_DIR      = $${UI_DIR}/build_linux_32
      }
    }

    DESTDIR = $$OUT_PWD/$$OBJECTS_DIR

    export(DESTDIR)
    export(MOC_DIR)
    export(OBJECTS_DIR)
    export(UI_DIR)
    export(LIBS)
    return($TARGET)
}

EOF
}

prepareVendorDir()
{
  local vendorDir=$1
  local vendorFilepath=${vendorDir}/vendor.pri.tmp
  local qompoterPriFilepath=${vendorDir}/qompote.pri
  mkdir -p "${vendorDir}"
  if [ "${IS_NO_QOMPOTE}" == "0" ]; then
    createQompotePri "${qompoterPriFilepath}"
    cat "${qompoterPriFilepath}" >  "${vendorFilepath}"
    { echo ''; echo 'INCLUDEPATH += $$PWD'; echo ' $$setLibPath()'; echo ''; } >> "${vendorFilepath}"
  fi
}

updateVendorPri()
{
  local vendorName=$1
  local packageName=$2
  local vendorDir=$3
  local qompoterPriFile=$4
  local vendorFilepath=${vendorDir}/vendor.pri.tmp
  local packageFullName=$vendorName/$packageName

  # Checks
  if [ "${IS_NO_QOMPOTE}" != "0" ]; then
    return;
  fi
  if [ ! -f "${qompoterPriFile}" ]; then
    logWarning "no 'qompoter.pri' found for this package"
    return
  fi

  # Update existing
  if  grep -q "## Start ${vendorName}/${packageName}" "${vendorFilepath}" ; then
    local packagePattern="\(## Start ${vendorName}\/${packageName}\).*\(## End ${vendorName}\/${packageName}\)"
    replaceBlock "${vendorFilepath}" "${packagePattern}" "\n\1\nqompoter-update-in-progress\n\2"
    replaceLineByFile "${vendorFilepath}" "qompoter-update-in-progress" "${qompoterPriFile}"
  # Add new at end
  else
    { echo "## Start ${packageFullName}"; cat "${qompoterPriFile}"; echo "## End ${packageFullName}"; } >> "${vendorFilepath}"
  fi
}

prepareQompoterLock()
{
  local qompoterLockFile=$1
  local projectFullName=$2
  cat <<- EOF > "${qompoterLockFile}"
{
  "name": "${projectFullName}",
  "date": "$(date --iso-8601=sec)",
  "require": {
  }
}
EOF
}

updateQompoterLockDate()
{
  local qompoterLockFile=$1
  # Update existing
  if  grep -q '"date":' "${qompoterLockFile}" ; then
    replaceLine "${qompoterLockFile}" '"date": ".*",' '"date": "'"$(date --iso-8601=sec)"'",'
  # Add new at end
  else
    insertAfter "${qompoterLockFile}" '^{' '  "date": "'"$(date --iso-8601=sec)"'",'
  fi
}

updateQompoterLock()
{
  local qompoterLockFile=$1
  local vendorName=$2
  local packageName=$3
  local version=$4
  local type=$5
  local url=$6
  local md5sum
  md5sum=$(getProjectMd5 "${VENDOR_DIR}/$packageName")
  local packageFullName=$vendorName/$packageName

  # Generate line
  local jsonData
  jsonData+="\"${packageFullName}\": { ";
  jsonData+="\"version\": \"${version}\", "
  jsonData+="\"type\": \"${type}\", "
  jsonData+="\"url\": \"${url}\", "
  jsonData+="\"md5sum\": \"${md5sum}\""
  jsonData+=" }"

  # Update existing
  if  grep -q "\"${packageFullName}\"" "${qompoterLockFile}" ; then
    replaceLine "${qompoterLockFile}" " *\(,\) *\"${vendorName}\/${packageName}\" *: *{.*}" "    \1${jsonData//\//\\/}"
  # Add new at end
  else
    if [ "${LAST_QOMPOTERLOCK_PART}" != '  "require": {' ]; then
      jsonData=",${jsonData}"
    fi
    insertAfter "${qompoterLockFile}" "${LAST_QOMPOTERLOCK_PART}" "    ${jsonData}"
  fi
  LAST_QOMPOTERLOCK_PART="\"${md5sum}\" }"
  # FIXME Add require-dev to lock file
}

downloadPackage()
{
  local repositoryPath=$1
  local vendorDir=$2
  local vendorName=$3
  VENDOR_NAME=$3
  local packageName=$4
  PROJECT_NAME=$4
  local requireName=$vendorName/$packageName
  local requireVersion=$5
  PACKAGE_VERSION=$5
  local selectedVersion=
  local qompoterLockFile=$6
  local packageDistUrl=$7
  local result=1
  local isSource=1
  if [[ "$requireVersion" == *"-lib" ]]; then
    isSource=0
  fi
  local requireBasePath=${repositoryPath}/${requireName}
  local requireLocalPath=${vendorDir}/${packageName}
  local qompoterPriFile=${requireLocalPath}/qompoter.pri
  local inqludeDistUrl

  echo "* ${requireName} ${requireVersion}"

  mkdir -p "${requireLocalPath}"

  # Search in Inqlude repository
  checkPackageInqludeVersion "${vendorName}" "${packageName}" "${requireVersion}" "${INQLUDE_FILENAME}"
  inqludeDistUrl=$(getPackageInqludeUrl "${vendorName}" "${packageName}" "${requireVersion}" "${INQLUDE_FILENAME}")
  # if [ -z "${packageDistUrl}" ] && [ ! -z "${inqludeDistUrl}" ]; then
  #   logDebug "  Use inqlude package \"${packageName}\" (${inqludeDistUrl})"
  #   packageDistUrl=${inqludeDistUrl}
  # elif [ -z "${packageDistUrl}" ]; then
  #   packageDistUrl=${requireBasePath}/${requireVersion}
  # fi

  # Sources
  if [ "${isSource}" -eq 1 ]; then
    # Git
    # Provided URL
    if [ ! -z "${packageDistUrl}" ] && isGitRepositories "${packageDistUrl}"; then
      packageDistUrl=${packageDistUrl}.git
      echo "  Downloading sources from Git..."
      logDebug "  URL has been provided (${packageDistUrl})"
      packageType="git"
      downloadPackageFromGit "${repositoryPath}" "${vendorDir}" "${vendorName}" "${packageName}" "${requireVersion}" "${packageDistUrl}"
      result=$?
      if [ "${result}" == "1" ] || [ "${result}" == "2" ]; then
        logWarning "error with Git, Qompoter will try downloading sources from scratch..."
      fi
    fi
    # Inqlude
    if [ "${result}" != "0" ] && [ "${result}" != "3" ] && [ "${result}" != "4" ] && [ ! -z "${inqludeDistUrl}" ] && isGitRepositories "${inqludeDistUrl}"; then
      packageDistUrl=${inqludeDistUrl}
      echo "  Downloading sources from Git..."
      logDebug "  Found in Inqlude repository (${packageDistUrl})"
      packageType="git"
      downloadPackageFromGit "${repositoryPath}" "${vendorDir}" "${vendorName}" "${packageName}" "${requireVersion}" "${packageDistUrl}"
      result=$?
      if [ "${result}" == "1" ] || [ "${result}" == "2" ]; then
        logWarning "error with Git, Qompoter will try downloading sources from scratch..."
      fi
    fi
    # Mostly HTTP URL
    if [ "${result}" != "0" ] && [ "${result}" != "3" ] && [ "${result}" != "4" ] && isGitRepositories "${requireBasePath}.git"; then
      packageDistUrl="${requireBasePath}.git"
      echo "  Downloading sources from Git..."
      logDebug "  Found in repository (${packageDistUrl})"
      packageType="git"
      downloadPackageFromGit "${repositoryPath}" "${vendorDir}" "${vendorName}" "${packageName}" "${requireVersion}" "${packageDistUrl}"
      result=$?
      if [ "${result}" == "1" ] || [ "${result}" == "2" ]; then
        logWarning "error with Git, Qompoter will try downloading sources from scratch..."
      fi
    fi
    # FIXME Check if requireBasePath does not already contain REPO_PATH with && [[ "${requireBasePath}" != "${REPO_PATH}"* ]]  but this is sometimes useful
    # Qompotist-fs
    if [ "${result}" != "0" ] && [ "${result}" != "3" ] && [ "${result}" != "4" ] && isGitRepositories "${REPO_PATH}/${requireName}/${packageName}.git"; then
      packageDistUrl="${REPO_PATH}/${requireName}/${packageName}.git"
      echo "  Downloading sources from Git..."
      logDebug "  Found in base repository (${packageDistUrl})"
      packageType="git"
      downloadPackageFromGit "${repositoryPath}" "${vendorDir}" "${vendorName}" "${packageName}" "${requireVersion}" "${packageDistUrl}"
      result=$?
      if [ "${result}" == "1" ] || [ "${result}" == "2" ]; then
        logWarning "error with Git, Qompoter will try downloading sources from scratch..."
      fi
    fi

    # Copy (also done if Git failed)
    if [ "${result}" == "1" ] || [ "${result}" == "2" ]; then
      if [ ! -d "${requireLocalPath}" ]; then
        mkdir -p "${requireLocalPath}"
      fi
      echo "  Downloading sources..."
      packageType="qompotist-fs"
      downloadPackageFromCp "${repositoryPath}" "${vendorDir}" "${vendorName}" "${packageName}" "${requireVersion}"
      result=$?
      packageDistUrl=${requireBasePath}/${PACKAGE_VERSION}
    fi
  # Lib
  else
    echo "  Downloading lib..."
    packageType="qompotist-fs"
    if [ -z "${packageDistUrl}" ] && [ ! -z "${inqludeDistUrl}" ]; then # Use Inqlude binary if any
      logDebug "  Use inqlude package \"${packageName}\" (${inqludeDistUrl})"
      packageType="inqlude"
      packageDistUrl=${inqludeDistUrl}
    fi
    downloadLibPackage "${repositoryPath}" "${vendorDir}" "${vendorName}" "${packageName}" "${requireVersion}" "${packageDistUrl}"
    result=$?
  fi

  # BY-PASS
  if [ "$result" == "4" ]; then
    echo -e "  ${C_SKIP}SKIPPED${C_END}"
    echo
    return 0
  # FAILURE
  elif [ "$result" != "0" ]; then
    echo -e "  ${C_FAIL}FAILURE${C_END}"
    echo
    return 1
  # DONE
  else
    updateVendorPri "${vendorName}" "${packageName}" "${vendorDir}" "${qompoterPriFile}"
    updateQompoterLock "${qompoterLockFile}" "${vendorName}" "${packageName}" "${PACKAGE_VERSION}" "${packageType}" "${PACKAGE_DIST_URL}"
    echo -e "  ${C_OK}done${C_END}"
    echo
  fi

  return 0
}

downloadPackageFromCp()
{
  local repositoryPath=$1
  local vendorDir=$2
  local vendorName=$3
  local packageName=$4
  local packageVersion=$5
  local selectedVersion
  local requireName=${vendorName}/${packageName}
  local requireBasePath=${repositoryPath}/${requireName}
  local requireLocalPath=${vendorDir}/${packageName}

 # Select the best version (if variadic version number provided)
  if [ "${packageVersion#*\*}" != "${packageVersion}" ]; then
    logDebug "  Search matching version"
    logTrace $(ls "${requireBasePath}" | LC_ALL=C sort --version-sort) # noquote for oneline
    selectedVersion=$(ls "${requireBasePath}" | LC_ALL=C sort --version-sort | getBestVersionNumber "$packageVersion")
    if [ -z "${selectedVersion}" ]; then
      echo "  Oups, no matching version for \"${packageVersion}\""
      return 2
    fi
    packageVersion=${selectedVersion}
    echo "  Selected version: ${packageVersion}"
  fi

  # Copy
  local packageDistUrl=${requireBasePath}/${packageVersion}
  if [ -d "${packageDistUrl}" ]; then
    logDebug "  Copy \"${packageDistUrl}\" to \"${requireLocalPath}\""
    cp -rf ${packageDistUrl}/* "${requireLocalPath}" \
      >> ${C_LOG_FILENAME} 2>&1
    PACKAGE_VERSION=${packageVersion}
    PACKAGE_DIST_URL=${packageDistUrl}
    return 0
  fi
  rm -rf "${requireLocalPath}"
  echo "  Error: no package found \"${packageDistUrl}\""
  return 1
}

downloadLibPackage()
{
  local repositoryPath=$1
  local vendorDir=$2
  local vendorName=$3
  local packageName=$4
  local packageVersion=$5
  local selectedVersion
  local packageDistUrl=$6
  local requireName=${vendorName}/${packageName}
  local requireBasePath=${repositoryPath}/${requireName}
  local requireLocalPath=${vendorDir}/${packageName}

  ## Package URL is provided
  # Download from HTTP
  if [[ ! -z ${packageDistUrl} ]] && [[ ${packageDistUrl} == "http"* ]]; then
    logDebug "  Download using package provided url"
    downloadLibFromHttp "${packageDistUrl}" "${requireLocalPath}"
    res=$?
    if [ "$res" == "0" ]; then
      PACKAGE_VERSION=${packageVersion}
      PACKAGE_DIST_URL=${packageDistUrl}
      return 0
    fi
    logWarning "cannot find provided \"${packageDistUrl}\", let's try another repository"
  fi

  ## Package URL is not provided: build it
  # Build package URL
  packageDistUrl=${requireBasePath}/${packageVersion}

  # Download from HTTP
  if [[ ${packageDistUrl} == "http"* ]]; then
    logDebug "  Download using package built url"
    # Try tarball
    downloadLibFromHttp "${packageDistUrl}.tar.gz" "${requireLocalPath}"
    res=$?
    if [ "$res" == "0" ]; then
      PACKAGE_VERSION=${packageVersion}
      PACKAGE_DIST_URL=${packageDistUrl}.tar.gz
      return 0
    fi
    logDebug "  Warning: cannot find \"${packageDistUrl}.tar.gz\", let's try with zip"

    # Try zip archive
    downloadLibFromHttp "${packageDistUrl}.zip" "${requireLocalPath}"
    res=$?
    if [ "$res" == "0" ]; then
      PACKAGE_VERSION=${packageVersion}
      PACKAGE_DIST_URL=${packageDistUrl}.zip
      return 0
    fi
    logDebug "  Warning: cannot find \"${packageDistUrl}.zip\", let's try another repository"
  fi

  # Select the best version (if variadic version number provided)
  if [ "${packageVersion#*\*}" != "${packageVersion}" ]; then
    logDebug "  Search matching version"
    logTrace $(ls "${requireBasePath}" | LC_ALL=C sort --version-sort) # noquote for oneline
    selectedVersion=$(ls "${requireBasePath}" | LC_ALL=C sort --version-sort | getBestVersionNumber "${packageVersion}")
    if [ -z "${selectedVersion}" ]; then
      echo "  Oups, no matching version for \"${packageVersion}\""
      return 2
    fi
    packageVersion=${selectedVersion}
    echo "  Selected version: ${packageVersion}"
  fi
  packageDistUrl=${requireBasePath}/${packageVersion}
  # Download from CP
  logDebug "  Copy using package built url"
  downloadLibFromCp "${packageDistUrl}" "${requireLocalPath}"
  res=$?
  if [ "$res" == "0" ]; then
    PACKAGE_VERSION=${packageVersion}
    PACKAGE_DIST_URL=${packageDistUrl}
    return 0
  fi

  ## Clear if failed
  rm -rf "${requireLocalPath}"
  echo "  Error: no library found \"${packageDistUrl}\""
  return $res
}

# Copy a tarball or an archive from HTTP
downloadLibFromHttp()
{
  local packageDistUrl=$1
  local requireLocalPath=$2
  local archive
  # archive=$(echo "${packageDistUrl}" | cut -d@ -f2 | cut -d/ -f2- | cut -d? -f1 | sed 's/\///')
  archive=${packageDistUrl##*/}
  archive=${archive%%\?*}

  logDebug "  Download \"${packageDistUrl}\" to \"${requireLocalPath}/${archive}\""
  wget "${packageDistUrl}" --directory-prefix="${requireLocalPath}" \
        >> ${C_LOG_FILENAME} 2>&1
  local res="$?"
  if [ "${res}" == "127" ]; then
    # wget missing, try with curl
    curl "${packageDistUrl}" --fail > "${requireLocalPath}/${archive}" \
          2>&1
    res="$?"
  fi
  # Download fail
  if [ "${res}" != "0" ]; then
    return ${res}
  fi

  logDebug "  Extract library tarball"
  if [[ ${packageDistUrl} == *".tar.gz" ]]; then
    tar -xf "${requireLocalPath}/${archive}" --directory "${requireLocalPath}" --overwrite --strip-components=1 \
        >> ${C_LOG_FILENAME} 2>&1
    res="$?"
  elif [[ ${packageDistUrl} == *".zip" ]]; then
    unzip -u "${requireLocalPath}/${archive}" -d "${requireLocalPath}" \
      >> ${C_LOG_FILENAME} 2>&1
    res="$?"
    mv -f ${requireLocalPath}/${packageVersion}/* "${requireLocalPath}"
  else
    logDebug "  Error: unknown archive packaging"
    return 1
  fi

  if [ "$res" == "0" ]; then
    logDebug "  Delete archive \"${archive}\""
    rm -f ${requireLocalPath}/${archive}*
    logDebug "  Move \"${requireLocalPath}/*lib_?*\" to \"${vendorDir}\""
    cp -rf ${requireLocalPath}/lib_* ${vendorDir} \
        && rm -rf ${requireLocalPath}/lib_* \
        >> ${C_LOG_FILENAME} 2>&1
    cp -rf ${requireLocalPath}/*lib ${vendorDir} \
        >> ${C_LOG_FILENAME} 2>&1 \
        && rm -rf ${requireLocalPath}/*lib ${vendorDir} \
        >> ${C_LOG_FILENAME} 2>&1
    PACKAGE_VERSION=${packageVersion}
    PACKAGE_DIST_URL=${packageDistUrl}
  fi
  return $res
}

downloadLibFromCp()
{
  local packageDistUrl=$1
  local requireLocalPath=$2

  if [ ! -d "${packageDistUrl}" ]; then
    return 1
  fi

  logDebug "  Copy \"${packageDistUrl}/*lib_?*\" to \"${vendorDir}\""
  cp -rf ${packageDistUrl}/lib_* ${vendorDir} \
      >> ${C_LOG_FILENAME} 2>&1
  cp -rf ${packageDistUrl}/*lib ${vendorDir} \
      >> ${C_LOG_FILENAME} 2>&1
  logDebug "  Copy \"${packageDistUrl}/include\" to \"${requireLocalPath}\""
  cp -rf ${packageDistUrl}/include ${requireLocalPath} \
      >> ${C_LOG_FILENAME} 2>&1
  cp -rf ${packageDistUrl}/qompoter.* ${requireLocalPath} \
      >> ${C_LOG_FILENAME} 2>&1
  cp -rf ${packageDistUrl}/*.md ${requireLocalPath} \
      >> ${C_LOG_FILENAME} 2>&1
  PACKAGE_VERSION=${packageVersion}
  PACKAGE_DIST_URL=${packageDistUrl}
  return 0
}

#**
# * @return 1 on generic error
# * @return 2 on git error
# * @return 3 on git warning (force required toby-pass and continue)
# * @return 4 when action is by-passed
# * @exit -1 on fatal issue
#**
downloadPackageFromGit()
{
  local repositoryPath=$1
  local vendorDir=$2
  local vendorName=$3
  local packageName=$4
  local packageVersion=$5
  local requireBranch=$5
  local gitPath=$6
  local requireLocalPath=${vendorDir}/${packageName}
  local isSource=1
  local gitError=0
  local hasChanged=0

  # Parse commit number in version
  if [[ ${packageVersion} == "#"* ]]; then
    packageVersion=$(echo "${packageVersion}" | cut -d'#' -f2)
    requireBranch=
  fi
  # Parse branch name in version
  if [[ ${packageVersion} == "dev-"* ]]; then
    packageVersion=${packageVersion/dev-/}
    requireBranch=${packageVersion}
    test "${requireBranch}" == "" && requireBranch="master"
  fi

  # Does not exist yet: clone
  if [ ! -d "${requireLocalPath}/.git" ]; then
    logTrace "git clone ${gitPath} ${requireLocalPath}"
    if ! git clone "${gitPath}" "${requireLocalPath}" > ${C_LOG_FILENAME} 2>&1; then
      logGitTrace $(cat "${C_LOG_FILENAME}")
      logDebug "  Oups, cannot clone the project"
      return 2
    fi
  fi
  logTrace "cd ${requireLocalPath}"
  cd "${requireLocalPath}" || ( echo "  Error: cannot go to ${requireLocalPath}" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
  local C_LOG_FILENAME_PACKAGE=../../${C_LOG_FILENAME}

  #~ FIXME Update remote
  # Git remote not already set
  logTrace "git remote -v"
  logGitTrace $(git remote -v)
  if [[ -z $(git remote -v | grep "${gitPath}") ]]; then
    if [[ ! -z $(git remote -v | grep "origin") ]]; then
      logDebug "  Change \"origin\" remote to \"${gitPath}\""
      logTrace "git remote set-url origin ${gitPath}"
      if ! git remote set-url origin "${gitPath}" > ${C_LOG_FILENAME_PACKAGE} 2>&1; then
        logGitTrace $(cat "${C_LOG_FILENAME_PACKAGE}")
        res=1
      fi
    else
      logDebug "  Add \"${gitPath}\" as \"origin\" remote"
      logTrace "git remote add origin ${gitPath}"
      if ! git remote add origin "${gitPath}" > ${C_LOG_FILENAME_PACKAGE} 2>&1; then
        logGitTrace $(cat "${C_LOG_FILENAME_PACKAGE}")
        res=1
      fi
    fi
  fi

  # Verify no manual changes and warning otherwize
  #~ FIXME Use also last commit number
  logTrace "git status -s"
  hasChanged=$(git status -s)
  if [ ! -z "${hasChanged}" ]; then
    if [ "${IS_BYPASS}" != "1" ] && [ "${IS_FORCE}" != "1" ]; then
      logWarning "there are manual updates on this project."
      echo "  Use --by-pass to continue without modifying this package."
      echo "  Use --force to discard change and continue."
      cd - > /dev/null 2>&1 || ( echo "  Error: cannot go back to ${currentPath}" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
      return 3
    elif [ "${IS_BYPASS}" == "1" ]; then
      logWarning "there are manual updates on this project. Ignore and continue."
      return 4
    else
      logWarning "there were manual updates on this project. Update forced."
    fi
  fi

  # Update
  logTrace "git fetch"
  if ! git fetch > ${C_LOG_FILENAME_PACKAGE} 2>&1; then
    logGitTrace $(cat "${C_LOG_FILENAME_PACKAGE}")
    echo "  Oups, cannot fetch \"${gitPath}\"..."
    cd - > /dev/null 2>&1 || ( echo "  Error: cannot go back to ${currentPath}" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
    return 2
  fi

  # Select the best version (if variadic version number provided)
  if [ "${packageVersion#*\*}" != "${packageVersion}" ]; then
    logDebug "  Search matching version"
    logTrace "git tag --list"
    logGitTrace $(git tag --list | LC_ALL=C sort --version-sort) # noquote for oneline
    local selectedVersion
    selectedVersion=$(git tag --list | LC_ALL=C sort --version-sort | getBestVersionNumber "${packageVersion}")
    if [ -z "${selectedVersion}" ]; then
      echo "  Oups, no matching version for \"${requireVersion}\""
      cd - > /dev/null 2>&1 || ( echo "  Error: cannot go back to ${currentPath}" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
      return 2
    fi
    packageVersion=${selectedVersion}
    requireBranch=${selectedVersion}
    echo "  Selected version: ${packageVersion}"
  fi

  # TODO Verify version availability?

  # Retrieve
  logTrace "git checkout -f ${packageVersion}"
  if ! git checkout -f "${packageVersion}" > ${C_LOG_FILENAME_PACKAGE} 2>&1; then
    logGitTrace $(cat "${C_LOG_FILENAME_PACKAGE}")
    echo "  Oups, \"${packageVersion}\" does not exist"
    cd - > /dev/null 2>&1 || ( echo "  Error: cannot go back to ${currentPath}" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
    return 2
  fi
  if [ "${requireBranch}" != "" ]; then
    logTrace "git pull origin ${requireBranch}"
    if ! git pull origin "${requireBranch}" > ${C_LOG_FILENAME_PACKAGE} 2>&1; then
      logGitTrace $(cat "${C_LOG_FILENAME_PACKAGE}")
      echo "  Oups, cannot pull... Is \"${requireBranch}\" really existing?"
      cd - > /dev/null 2>&1 || ( echo "  Error: cannot go back to ${currentPath}" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
      return 2
    fi
  fi
  # Reset
  logDebug "  Reset any local modification just to be sure"
  logTrace "git reset --hard ${packageVersion}"
  git reset --hard "${packageVersion}" > ${C_LOG_FILENAME_PACKAGE} 2>&1
  logGitTrace $(cat "${C_LOG_FILENAME_PACKAGE}")

  cd - > /dev/null 2>&1 || ( echo "  Error: cannot go back to ${currentPath}" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)

  if [ ! -d "${requireLocalPath}/.git" ]; then
    gitError=1
  fi
  PACKAGE_VERSION=${packageVersion}
  PACKAGE_DIST_URL=${gitPath}
  return $gitError
}

checkQompoterFile()
{
  local qompoterFile=$1
  if [ ! -f "${qompoterFile}" ]; then
      echo "Qompoter could not find a '${qompoterFile}' file in '${PWD}'"
      echo "To initialize a project, please create a '${qompoterFile}' file as described in the https://github.com/Fylhan/qompoter/blob/master/docs/Qompoter-file.md"
    return 100
  fi
}

isGitRepositories()
{
  local gitUrlOrRepository=$1
  # Empty? Abort
  if [ -z "${gitUrlOrRepository}" ]; then
    return 1;
  fi
  # Existing Git repository in file system: ok
  if [ -d "${gitUrlOrRepository}" ]; then
    return 0
  fi
  local gitRepositories=("github" "git.kde" "gitlab" "gitorious" "code.qt.io" "git.freedesktop" "framagit")
  # Repository path confirms it is a well-known Git repository: ok
  for i in "${gitRepositories[@]}"; do
    if [[ "${gitUrlOrRepository}" == *"$i"* ]]; then
      return 0;
    fi
  done
  return 1
}

getBestVersionNumber()
{
  local versionPattern=$1
  #~ FIXME Sort version number using natural sort (v1.10 > v1.3)
    if [ "${IS_STABLE_ONLY}" == "1" ]; then
      grep "v\?${versionPattern}\$" | grep -v -e "-\(alpha\|beta\|RC[0-9]*\|[0-9]*\)$" | tail -1
    else
      grep "v\?${versionPattern}\$" | tail -1
    fi
}

getProjectMd5()
{
  #~ See http://stackoverflow.com/questions/1657232/how-can-i-calculate-an-md5-checksum-of-a-directory
  local projectDir=$1
  (find "${projectDir}" -type f -not -path "*.git*" \
      | while read f; do md5sum "$f"; done; find "${projectDir}" -type d -not -path "*.git*" ) \
    | LC_ALL=C sort --version-sort \
    | md5sum \
    | sed -e 's/ *- *//'
}

#**
# * Retrieve packages info from Qompoter file
# * @param Qompoter file name
# * @return list of <vendor name>/<project name>/<version number>
#**
getProjectRequires()
{
  local qompoterFile=$1
  # Search for "require"
  # and remove quote ("), "[require,", "] "
  # replace space by slash
  jsonh < "${qompoterFile}" \
   | grep -E "\[\"require${IS_INCLUDE_DEV}\",\".*\"\]" \
   | sed -r "s/\"//g;s/\[require${IS_INCLUDE_DEV},//g;s/\]	/ /g" \
   | tr ' ' '/'
}

#**
# * Retrieve package info from Qompoter file
# * @param Qompoter file name
# * @param Project full name <vendor name>/<project name>
# * @return <version number>
#**
getOnePackageVersion()
{
  local qompoterFile=$1
  local projectFullName=$2

  jsonh < "${qompoterFile}" \
   | grep -E "\[\"require(-dev)?\",\"${projectFullName}\"\]" \
   | sed -r -e "s/\"//g;s/\[require.*\]\s*//"
}

#**
# * Retrieve packages info from Qompoter lockfile
# * @param Qompoter file name
# * @return list of <vendor name>/<project name>/<version number>
#**
getProjectRequiresFromLock()
{
  local qompoterFile=$1
  # Search for "require"
  # and remove quote ("), "[require,", "] "
  # replace space by slash
  jsonh < "${qompoterFile}" \
   | grep -E "\[\"require${IS_INCLUDE_DEV}\",\".*\",\"version\"\]" \
   | sed -r "s/\"//g;s/\[require${IS_INCLUDE_DEV},//g;s/,version//g;s/\]	/ /g" \
   | tr ' ' '/'
}

#**
# * Retrieve a project MD5 sum from Qompoter lockfile
# * @param Qompoter file name
# * @param Project full name <vendor name>/<project name>
# * @return <md5 value>
#**
getProjectMd5FromLock()
{
  local qompoterFile=$1
  local projectFullName=$2
  # Search for "require"
  # and remove quote ("), "[require,", "] "
  # replace space by slash
  jsonh < "${qompoterFile}" \
   | grep -E "\[\"require${IS_INCLUDE_DEV}\",\"${projectFullName}\",\"md5sum\"\]" \
   | sed -r "s/\"//g;s/\[require${IS_INCLUDE_DEV},//g;s/,md5sum//g;s/\]	/ /g" \
   | tr ' ' '/'
}

#**
# * Retrieve package info from Qompoter lockfile
# * @param Qompoter file name
# * @param Searched package info
# * @return <vendor name>/<project name>
#**
getOnePackageNameFromLock()
{
  local qompoterFile=$1
  local packageName=$2

  # Search for "require"
  # and remove quote ("), "[require,", "] "
  # replace space by slash
  jsonh < "${qompoterFile}" \
   | grep -E "\[\"require(-dev)?\",\".*/${packageName}\",\"version\"\]" \
   | sed -r "s/\"//g;s/\[require(-dev)?,//g;s/,version//g;s/\]	.*//g"
}

#**
# * Retrieve package info from Qompoter lockfile
# * @param Qompoter file name
# * @param Searched package info
# * @return <vendor name>/<project name>/<version number>
#**
getOnePackageFullNameFromLock()
{
  local qompoterFile=$1
  local packageName=$2

  # Search for "require"
  # and remove quote ("), "[require,", "] "
  # replace space by slash
  jsonh < "${qompoterFile}" \
   | grep -E "\[\"require(-dev)?\",\".*/${packageName}\",\"version\"\]" \
   | sed -r "s/\"//g;s/\[require(-dev)?,//g;s/,version//g;s/\]	/ /g" \
   | tr ' ' '/'
}

#**
# * Retrieve project info from Qompoter file
# * @param Qompoter file name
# * @return <project name>
#**
getProjectName()
{
  local qompoterFile=$1
  jsonh < "${qompoterFile}" \
   | grep -E "\[\"name\"\]" \
   | sed -e 's/"//g;s/\[name\]\s*//;s/.*\///'
}


#**
# * Retrieve project info from Qompoter file
# * @param Qompoter file name
# * @return <vendor name>/<project name>
#**
getProjectFullName()
{
  local qompoterFile=$1
  jsonh < "${qompoterFile}" \
   | grep -E "\[\"name\"\]" \
   | sed -e 's/"//g;s/\[name\]\s*//'
}

getRelatedRepository()
{
  local qompoterFile=$1
  local requireName=$2/$3
  local repositoryPathFromQompoterFile
  #~ TODO Let also accept repositories/<package name>/repository
  repositoryPathFromQompoterFile=`jsonh < "${qompoterFile}" \
   | grep -E "\[\"repositories\",\"${requireName}\"\]" \
   | sed -r "s/\"//g;s/\[repositories,.*\]\t*//g"`
  if [ "${repositoryPathFromQompoterFile}" != "" ] && [[ "${repositoryPathFromQompoterFile}" != "{url"* ]]; then
    echo "${repositoryPathFromQompoterFile}"
  else
    echo ${REPO_PATH}
  fi
}

getRelatedUrl()
{
  local qompoterFile=$1
  local requireName=$2/$3
  local packageUrlFromQompoterFile
  packageUrlFromQompoterFile=`jsonh < "${qompoterFile}" \
   | grep -E "\[\"repositories\",\"${requireName}\",\"url\"\]" \
   | sed -r "s/\"//g;s/\[repositories,.*,url\]\t*//g"`
  echo "${packageUrlFromQompoterFile}"
}

downloadQompoterFilePackages()
{
  local qompoterFile=$1
  local qompoterLockFile=$2
  local vendorDir=$3
  local globalRes=0
  local requires
  requires=$(getProjectRequires "${qompoterFile}")

  for packageInfo in ${requires}; do
      local vendorName
      local projectName
      local version
      vendorName=$(echo "${packageInfo}" | cut -d'/' -f1)
      projectName=$(echo "${packageInfo}" | cut -d'/' -f2)
      version=$(echo "${packageInfo}" | cut -d'/' -f3)
      #~ Skip if already installed
      test "${DOWNLOADED_PACKAGES#* $projectName }" != "$DOWNLOADED_PACKAGES" && continue
      #~ Download
      local repo
      local url
      repo=$(getRelatedRepository "${qompoterFile}" "${vendorName}" "${projectName}")
      url=$(getRelatedUrl "${qompoterFile}" "${vendorName}" "${projectName}")
      downloadPackage "${repo}" "${vendorDir}" "${vendorName}" "${projectName}" "${version}" "${qompoterLockFile}" "${url}"
      #~ Exit on error if no force
      local returnCode=$?
      if [ "${returnCode}" != "0" ]; then
        globalRes=${returnCode}
        test "${IS_BYPASS}" == "0" && test "${IS_FORCE}" == "0" && return 1
      fi
      DOWNLOADED_PACKAGES="${DOWNLOADED_PACKAGES} ${projectName} "
      if [ -f "${vendorDir}/${projectName}/qompoter.json" ]; then
        NEW_SUBPACKAGES="${NEW_SUBPACKAGES} ${vendorDir}/${projectName}/qompoter.json"
      fi
  done
  return $globalRes
}

updateVendorDirFromQompoterFile()
{
  local qompoterFile=$1
  if [ -f "${qompoterFile}" ]; then
    local vendorDirFromQompoterFile
    vendorDirFromQompoterFile=`jsonh < "${qompoterFile}" \
     | grep -E "\[\"vendor-dir\"\]" \
     | sed -r "s/\"//g;s/\[vendor-dir\]//g"`
    if [ "${vendorDirFromQompoterFile}" != "" ]; then
      VENDOR_DIR=${vendorDirFromQompoterFile}
    fi
  fi
}

minifyInqludeFile()
{
  local inqludeAllFile=$1
  jsonh < "${inqludeAllFile}" \
    | grep -e "name\"\]" -e "\"version\"\]" -e "\"summary\"\]" -e "\"licenses\"\]" -e "\"maturity\"\]" -e "\"platforms\"\]" -e "\"urls\",\"vcs\"\]" -e "\"packages\",\"source\"\]"
}

getInqludeId()
{
  local packageName=$1
  local inqludePackages=$2

  local packageId=`echo ${inqludePackages} \
   | grep -E "\[[0-9]+,\"name\"\]\\s*\"${packageName}\"" -o \
   | sed -r "s/\[([0-9]+),\"name\"\]\\s*\"${packageName}\"/\1/"`
  test -z "${packageId}" && return 3
  echo ${packageId}
}

checkPackageInqludeVersion()
{
  local vendorName=$1
  local packageName=$2
  local packageVersion=$3
  local inqludeAllFile=$3
  local packageId
  local packagePath
  local existingVersion

  #~ Load inqlude repository
  local inqludePackages=${INQLUDE_ALL_MIN_CONTENT}
  if [ "${inqludeAllFile}" != "" ]; then
    if [ -f "${inqludeAllFile}" ]; then
      inqludePackages=$(minifyInqludeFile "${inqludeAllFile}")
    fi
  fi

  #~ Search ${packageName}
  packageId=$(getInqludeId "${packageName}" "${inqludePackages}")
  test -z "${packageId}" && return 3
  existingVersion=$(getPackageInqludeData "${packageId}" "version" "${inqludePackages}")

  # Select the best version (if variadic version number provided)
  if [ "${packageVersion#*\*}" != "${packageVersion}" ]; then
    logDebug "  Search matching version"
    logTrace "${packageVersion}"
    local selectedVersion
    selectedVersion=$(echo "v${existingVersion}" | grep -e "${packageVersion}")
    if [ -z "${selectedVersion}" ]; then
      return 2
    fi
    packageVersion=${selectedVersion}
    PACKAGE_VERSION=${packageVersion}
    echo "  Selected version: ${packageVersion}"
  fi
  if [ "v${existingVersion}" != "${packageVersion}" ]; then
    echo "  Warning: there may be no such inqlude package as ${packageVersion}, try v${existingVersion} if it fails"
    return 1
  fi
  return 0
}

#**
# * Retrieve project URL in the Inqlude repository
# * @param Vendor name
# * @param Project name
# * @param Project version
# * @param Inqlude repository file
# * @return 3 not found
# * @return 4 package found but is lib but source is requested (or vice versa)
# * @return package url
#**
getPackageInqludeUrl()
{
  local vendorName=$1
  local packageName=$2
  local packageVersion=$3
  local inqludeAllFile=$4
  local packageId
  local packagePath
  local existingVersion

  #~ Load inqlude repository
  local inqludePackages=${INQLUDE_ALL_MIN_CONTENT}
  if [ "${inqludeAllFile}" != "" ]; then
    if [ -f "${inqludeAllFile}" ]; then
      inqludePackages=$(minifyInqludeFile "${inqludeAllFile}")
    fi
  fi

  #~ Search ${packageName}
  packageId=$(getInqludeId "${packageName}" "${inqludePackages}")
  test -z "${packageId}" && return 3
  existingVersion=$(getPackageInqludeData "${packageId}" "version" "${inqludePackages}")
  # Check that Inqlude does not store a lib version when a source version is required
  if [[ "$existingVersion" == *"lib" ]] && [[ "$packageVersion" != *"lib" ]]; then
      return 4
  fi

  #~ Search VCS URL for ${packageId}
  packagePath=$(getPackageInqludeData "${packageId}" "urls/vcs" "${inqludePackages}")
  if [[ "${packagePath}" != "" ]]; then
    if [[ "${packagePath}" == *"projects.kde.org"* ]]; then
      packagePath="git://anongit.kde.org/${packageName}"
    elif [[ "${packagePath}" == *"cgit.freedesktop.org"* ]]; then
      packagePath="https://anongit.freedesktop.org/git/${vendorName}/${packageName}"
    fi

    isGitRepositories "${packagePath}" && \
      echo "${packagePath}" && return
  fi

  #~ Search source URL for ${packageName}
  packagePath=$(getPackageInqludeData "${packageId}" "packages/source" "${inqludePackages}")
  test -z "${packagePath}" && return 3
  echo "${packagePath}"
}

getPackageInqludeData()
{
  local packageId=$1
  local keys=`echo ${2} | sed -r 's/\//\",\"/'`
  local inqludePackages=$3

  echo ${inqludePackages} \
   | grep -E "\[${packageId},\"${keys}\"\]\\s*\"([^\"]*)\"" -o \
   | sed -r "s/\[${packageId},\"${keys}\"\]\\s*\"([^\"]*)\"/\1/"
}

exportAction()
{
  local qompoterFile=$1

  checkQompoterFile "${qompoterFile}" --quiet || return 100
  local vendorBackup
  vendorBackup=$(date +"%Y-%m-%d")_$(getProjectName "${qompoterFile}")_${VENDOR_DIR}.zip
  if [ -f "${vendorBackup}" ]; then
    rm "${vendorBackup}"
  fi

  if [ -d "${VENDOR_DIR}" ]; then
    zip "${vendorBackup}" -r "${VENDOR_DIR}" \
      >> ${C_LOG_FILENAME} 2>&1
    echo "Exported to ${vendorBackup}"
  else
    echo "Nothing to do: no '${VENDOR_DIR}' dir"
    return 0
  fi
}

initAction()
{
  local vendorName=$1
  local packageName=$2
  local requireVersion=$3
  local requireName=${vendorName}/${packageName}
  local qompoterFile=$4
  local qtProFile="${packageName}.pro"
  local qtGlobalPriFile='.qmake.conf'
  local gitlabciFile='.gitlab-ci.yml'

  echo "Init ${requireName} ${requireVersion}..."
  echo

  local dirs=('src' 'test')
  for i in "${dirs[@]}"; do
    if [ ! -d "${i}" ]; then
      echo "* Create \"${i}\" dir"
      mkdir "${i}"
    else
      echo "* Do not override \"${i}\" dir"
    fi
  done

  local files=('README.md' 'changelogs.md')
  for i in "${files[@]}"; do
    if [ ! -f "${i}" ]; then
      echo "* Create \"${i}\" file"
      touch "${i}"
    else
      echo "* Do not override \"${i}\" file"
    fi
  done

  local qtFiles=("${qtProFile}" "${qtGlobalPriFile}" "src/src.pro" "test/test.pro")
  local qompoterFiles=("${qompoterFile}")
  local qompoterLibFiles=("qompoter.pri")
  # qompoter.json
  if [ "${IS_FORCE}" == "1" ] || [ ! -f "${qompoterFile}" ]; then
    echo "* Create \"${qompoterFile}\" file"
    cat <<- EOF > "${qompoterFile}"
{
    "name": "${requireName}"
}
EOF
  else
    echo "* Do not override \"${qompoterFile}\" file"
  fi

  # *.pro
  if [ "${IS_FORCE}" == "1" ] || [ ! -f "${qtProFile}" ]; then
    echo "* Create \"${qtProFile}\" file"
    cat <<- EOF > "${qtProFile}"
TEMPLATE = subdirs

!testcase {
    SUBDIRS += src
}
testcase {
    SUBDIRS += test
}

OTHER_FILES += \\
    .gitlab-ci.yml \\
    .qmake.conf \\
    qompoter.json \\
    qompoter.pri \\
    README.md \\
    changelogs.md \\
EOF
  else
    echo "* Do not override \"${qtProFile}\" file"
  fi
  # src.pro
  if [ "${IS_FORCE}" == "1" ] || [ ! -f "src/src.pro" ]; then
    echo "* Create \"src/src.pro\" file"
    cat <<- EOF > src/src.pro
INCLUDEPATH += \$\$PWD

# Please check ".qmake.conf" file to update app name or version number
TARGET = \$\${APPNAME}
VERSION = \$\${APPVERSION}
TEMPLATE = app

# Dependencies
CONFIG += c++11
QT += network
#CONFIG += ui
ui {
    greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
}
else {
    QT -= gl gui
    LIBS -= -lQt5GUI -lGL
}

include(\$\$PWD/../vendor/vendor.pri)
\$\$setBuildDir()
message("\$\${APPNAME} [ build folder is \$\${OBJECTS_DIR} ]")
EOF
  else
    echo "* Do not override \"src/src.pro\" file"
  fi
  # test.pro
  if [ "${IS_FORCE}" == "1" ] || [ ! -f "test/test.pro" ]; then
    echo "* Create \"test/test.pro\" file"
    cat <<- EOF > test/test.pro
DEPENDPATH += \$\$PWD \$\$PWD/testcase

CONFIG += autotester
include(\$\$PWD/../src/src.pro)
TARGET = \$\${APPNAME}-test

#HEADERS += \\

SOURCES += \\
    \$\$PWD/TestRunner.cpp \\

# Skip install
target.path = \$\${OUT_PWD}
INSTALLS = target
EOF
  else
    echo "* Do not override \"test/test.pro\" file"
  fi
  # qompoter.pri
  if [ "${IS_FORCE}" == "1" ] || [ ! -f "qompoter.pri" ]; then
    echo "* Create \"qompoter.pri\" file"
    cat <<- EOF > qompoter.pri
${packageName}-lib {
    LIBNAME = ${packageName}
    IMPORT_INCLUDEPATH = \$\$PWD/\$\$LIBNAME/include
    IMPORT_LIBPATH = \$\$PWD/\$\$LIBPATH
    INCLUDEPATH += \$\$IMPORT_INCLUDEPATH
    LIBS += -L\$\$IMPORT_LIBPATH -l\$\$getLibName(\$\${LIBNAME}, "Qt")
    DEFINES += QOMP_$(echo "${packageName}" | tr /a-z/ /A-Z/)
}

${packageName} {
    #HEADERS += \\
    #    \$\$PWD/${packageName}/src/....h \\

    #SOURCES += \\
    #    \$\$PWD/${packageName}/src/....cpp \\

    INCLUDEPATH += \\
        \$\$PWD/${packageName} \\
        \$\$PWD/${packageName}/src \\

    DEFINES += QOMP_$(echo "${packageName}" | tr /a-z/ /A-Z/)
}
EOF
  else
    echo "* Do not override \"qompoter.pri\" file"
  fi

  # .qmake.conf
  if [ "$IS_FORCE" == "1" ] || [ ! -f "${qtGlobalPriFile}" ]; then
    echo "* Create \"${qtGlobalPriFile}\" file"
    cat <<- EOF > ${qtGlobalPriFile}
# Included into every .pro and .pri files
VENDORNAME = ${vendorName}
APPNAME = ${packageName}
APPVERSION = ${requireVersion}
win32 {
    BUILDDATE = \$\$system("data /t")
} else {
    BUILDDATE = \$\$system("date --rfc-3339=date")
}
DEFINES += VENDORNAME=\\\\\\"\$\${VENDORNAME}\\\\\\"
DEFINES += APPNAME=\\\\\\"\$\${APPNAME}\\\\\\"
DEFINES += APPVERSION=\\\\\\"\$\${APPVERSION}\\\\\\"
DEFINES += BUILDDATE=\\\\\\"\$\${BUILDDATE}\\\\\\"
EOF
  else
    echo "* Do not override \"${qtGlobalPriFile}\" file"
  fi

  # .gitlab-ci.yml
  if [ "$IS_FORCE" == "1" ] || [ ! -f "${gitlabciFile}" ]; then
    echo "* Create \"${gitlabciFile}\" file"
    cat <<- EOF > ${gitlabciFile}
image: gcc

before_script:
#  - sudo yum --enablerepo=extras install epel-release
#  - sudo yum install -y qt5-qtbase qt5-qtbase-devel
#  - sudo yum install npm
#  - sudo npm install -g qompoter

build:
  stage: build
  script:
    - qompoter install --repo http://gitlab-ci-token:\${CI_BUILD_TOKEN}@gitlab.lan.trialog.com
    - mkdir ../build && cd ../build
    - qmake-qt5 ../\${CI_PROJECT_NAME}/\${CI_PROJECT_NAME}.pro
    - make
EOF
  else
    echo "* Do not override \"${gitlabciFile}\" file"
  fi

  # .gitignore
  if [ "$IS_FORCE" == "1" ] || [ ! -f ".gitignore" ]; then
    echo "* Create \".gitignore\" file"
    cat <<- EOF > .gitignore
.user
*.un~
*.swp
*.zip
*.tar*
*.log
*.lock
*.pdf
Thumbs.db
build-*
vendor
EOF
  else
    echo "* Do not override \".gitignore\" file"
  fi

  echo
}

#~ To be tested with: attica (Git url), diff-match-path (Unknown VCS but download url), kdtools (no url), unknown-package (not found)
inqludeSearchAction()
{
  local vendorName=$1
  local packageName=$2
  local requireVersion=$3
  local requireName=${vendorName}/${packageName}
  local inqludeAllFile=$4

  logDebug "  Inqlude repository last update: ${INQLUDE_ALL_CONTENT_LAST_UPDATE}"
  logDebug "  Load inqlude repository"
  logDebug
  local inqludePackages=${INQLUDE_ALL_MIN_CONTENT}
  if [ "${inqludeAllFile}" != "" ]; then
    if [ -f "${inqludeAllFile}" ]; then
      logDebug "  Prepare the provided inqlude repository file"
      inqludePackages=$(minifyInqludeFile "${inqludeAllFile}")
    else
      echo "  No such file \"${inqludeAllFile}\""
      echo "  Qompoter will use the default inqlude repository file"
      echo
    fi
  fi

  echo "* ${requireName} ${requireVersion}"

  logDebug "  Search ${packageName}"
  local packageId
  packageId=$(getInqludeId "${packageName}" "${inqludePackages}")
  if [ -z "${packageId}" ]; then
    logDebug "  Not found"
    echo
    return 3
  fi

  logDebug "  Search info about ${packageName} (${packageId})"
  local name=`getPackageInqludeData ${packageId} "display_name" "${inqludePackages}"`
  local version=`getPackageInqludeData ${packageId} "version" "${inqludePackages}"`
  local summary=`getPackageInqludeData ${packageId} "summary" "${inqludePackages}"`
  local vcsUrl=`getPackageInqludeData ${packageId} "urls/vcs" "${inqludePackages}"`
  local downloadUrl=`getPackageInqludeData ${packageId} "packages/source" "${inqludePackages}"`
  test ! -z "${name}" && echo "  ${name} ${version}"
  test ! -z "${vcsUrl}" && echo "  VCS: ${vcsUrl}"
  test ! -z "${downloadUrl}" && echo "  Download: ${downloadUrl}"
  test -z "${vcsUrl}" && test -z "${downloadUrl}" && echo "  No usable URL"

  echo
}

inqludeMinifyAction()
{
  local inqludeAllFile=$1

  if [ ! -f "${inqludeAllFile}" ]; then
    echo "Qompoter could not find a '${inqludeAllFile}' file in '${PWD}'"
    return 100
  fi

  echo "Minifying '${inqludeAllFile}' to '${inqludeAllFile}.min'"
  minifyInqludeFile ${inqludeAllFile} \
    > ${inqludeAllFile}.min
  echo
}

inspectAction()
{
  local qompoterFile=$1
  local qompoterLockFile
  local vendorDir=$2
  local globalRes=0
  qompoterLockFile=$(echo "${qompoterFile}" | cut -d'.' -f1).lock

  # Check
  checkQompoterFile "${qompoterLockFile}" || return 100
  if [ ! -d "${vendorDir}" ]; then
    echo "Nothing to do: no '${VENDOR_DIR}' dir"
    return 0
  fi

  # Loop over lock file
  local changes=0
  local requires
  requires=$(getProjectRequiresFromLock "${qompoterLockFile}")
  for packageInfo in ${requires}; do
    local vendorName
    vendorName=$(echo "${packageInfo}" | cut -d'/' -f1)
    local projectName
    projectName=$(echo "${packageInfo}" | cut -d'/' -f2)
    local projectFullName="${vendorName}/${projectName}"
    local version
    version=$(echo "${packageInfo}" | cut -d'/' -f3)
    local expectedMd5Sum
    expectedMd5Sum=$(getProjectMd5FromLock "${qompoterLockFile}" "${projectFullName}" | cut -d'/' -f3)
    local actualMd5Sum
    actualMd5Sum=$(getProjectMd5 "${vendorDir}/${projectName}")
    local differs=
    test "${actualMd5Sum}" != "${expectedMd5Sum}" && let changes=${changes}+1 && differs="${C_INFO} *${C_END}"
    if [[ "${IS_ALL}" == "1" ]] || [[ ! -z "${differs}" ]]; then
      echo -e "* ${projectFullName} (${version}${differs})"
      if [ -d "${vendorDir}/${projectName}/.git" ]; then
        cd "${vendorDir}/${projectName}" || ( echo "  Error: cannot go to !$" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
        git status -sb
        if [[ ! -z $"${differs}" ]] && ( [ "$IS_VERBOSE" == "1" ] || [ "$IS_VERBOSE" == "2" ] || [ "$IS_VERBOSE" == "3" ] ); then
          git diff
        fi
        cd ../../ || ( echo "  Error: cannot go to !$" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
      fi
      echo
    fi
  done

  if [ "${changes}" == "0" ]; then
      echo -e "${C_OK}Great! There is no manual change${C_END}"
  elif [ "${changes}" == "1" ]; then
      echo -e "Take care, there is ${C_INFO}1${C_END} manual change"
  else
    echo -e "Take care, there are ${C_INFO}${changes}${C_END} manual changes"
  fi
  echo
}

recursiveInstallFromQompoterFile()
{
  local qompoterFile=$1
  local qompoterLockFile=$2
  local vendorDir=$3
  local vendorPriFile
  local globalRes=0

  NEW_SUBPACKAGES=${qompoterFile}
  vendorPriFile=${vendorDir}/vendor.pri

  local depth=0
  while [ "${depth}" -lt "${DEPTH_SIZE}" ] && [ -n "${NEW_SUBPACKAGES}" ]; do
    depth=$((depth+1))
    local newSubpackages=${NEW_SUBPACKAGES}
    NEW_SUBPACKAGES=""
    for subQompoterFile in ${newSubpackages}; do
      downloadQompoterFilePackages "${subQompoterFile}" "${qompoterLockFile}" "${vendorDir}"
      #~ Exit on error if no force
      local returnCode=$?
      if [ "${returnCode}" != "0" ]; then
        globalRes=${returnCode}
        test "${IS_BYPASS}" == "0" && test "${IS_FORCE}" == "0" && return 1
      fi
      IS_INCLUDE_DEV=
    done
    if [ "$depth" == "$DEPTH_SIZE" ] && [ -n "${NEW_SUBPACKAGES}" ]; then
      echo -e "${C_FAIL}WARNING${C_END} There are still packages to download but maximal recursive depth of $DEPTH_SIZE have been reached."
    fi
  done
  return $globalRes
}

installAction()
{
  local qompoterFile=$1
  local qompoterLockFile
  local vendorDir=$2
  local vendorPriFile
  local globalRes=0

  qompoterLockFile="${qompoterFile/.json/}.lock"
  vendorPriFile=${vendorDir}/vendor.pri

  checkQompoterFile "${qompoterFile}" || return 100
  prepareVendorDir "${vendorDir}"
  prepareQompoterLock "${qompoterLockFile}.tmp" "$(getProjectFullName "${qompoterFile}")"

  recursiveInstallFromQompoterFile "${qompoterFile}" "${qompoterLockFile}.tmp" "${vendorDir}"
  globalRes=$?

  if [[ "${globalRes}" == 0 ]] || [[ "${IS_BYPASS}" == "1" ]]; then
    mv "${qompoterLockFile}.tmp" "${qompoterLockFile}"
    mv "${vendorPriFile}.tmp" "${vendorPriFile}"
  else
    rm "${qompoterLockFile}.tmp"
    rm "${vendorPriFile}.tmp"
  fi
  return $globalRes
}

installOnePackageAction()
{
  local qompoterFile=$1
  local qompoterLockFile
  local vendorDir=$2
  local vendorPriFile
  local requireName=${3}/${4}
  local requireVersion=$5
  local qompoterFilePackage="qompoter-installone.json"
  local globalRes

  # Search version number if needed
  if [ -z "${requireVersion}" ]; then
    if [ ! -f "${qompoterFile}" ]; then
      echo "* ${requireName} <missing version>"
      echo "  No version number in command line and no Qompoter file \"${qompoterFile}\""
      echo -e "  ${C_FAIL}FAILURE${C_END}"
      echo
      return 100
    fi
    requireVersion=$(getOnePackageVersion "${qompoterFile}" "${requireName}")
    if [ -z "${requireVersion}" ]; then
      echo "* ${requireName} <missing version>"
      echo "  No version number provided in command line and none provided in Qompoter file"
      echo -e "  ${C_FAIL}FAILURE${C_END}"
      echo
      return 101
    fi
  fi
  # Prepare lock file
  qompoterLockFile="${qompoterFile/.json/}.lock"
  if [ -f "${qompoterLockFile}" ]; then
    cp "${qompoterLockFile}" "${qompoterLockFile}.tmp"
  else
    prepareQompoterLock "${qompoterLockFile}.tmp" "qompoter/installone"
  fi
  updateQompoterLockDate "${qompoterLockFile}.tmp"
  # Prepare vendor dir
  vendorPriFile=${vendorDir}/vendor.pri
  if [ -f "${vendorPriFile}" ]; then
    cp "${vendorPriFile}" "${vendorPriFile}.tmp"
  else
    prepareVendorDir "${vendorDir}"
  fi

  # Load
  echo "{ \"require\": {\"${requireName}\": \"${requireVersion}\" } }" > ${qompoterFilePackage}
  recursiveInstallFromQompoterFile "${qompoterFilePackage}" "${qompoterLockFile}.tmp" "${vendorDir}"
  globalRes=$?

  rm ${qompoterFilePackage}
  if [[ "${globalRes}" == 0 ]]; then
    mv "${qompoterLockFile}.tmp" "${qompoterLockFile}"
    mv "${vendorPriFile}.tmp" "${vendorPriFile}"
  else
    rm "${qompoterLockFile}.tmp"
    rm "${vendorPriFile}.tmp"
  fi
  return $globalRes
}

jsonhAction()
{
  local qompoterFile=$1
  jsonh < "${qompoterFile}"
}

md5sumAction()
{
  local projectDir=$1
  getProjectMd5 "${projectDir}"
}

updateAction()
{
  echo "Not implemented yet";
  return 1
}

requireListAction()
{
  local qompoterFile=$1

  checkQompoterFile "${qompoterFile}" || return 100
  for packageInfo in $(getProjectRequires "${qompoterFile}"); do
    echo "* ${packageInfo}"
  done
  echo
}

requireAction()
{
  echo "Not implemented yet";
  return 1
}

repoExportAction()
{
  local qompoterFile=$1
  local qompoterLockFile
  local vendorDir=$2
  local packages
  qompoterLockFile=$(echo "${qompoterFile}" | cut -d'.' -f1).lock

  checkQompoterFile "${qompoterLockFile}" || return 100
  if [ ! -d "${vendorDir}" ]; then
    echo "Nothing to do: no '${VENDOR_DIR}' dir"
    return 0
  fi

  packages=$(ls "${vendorDir}" | grep -v -e "\(lib_.*\|qompote\.pri\|vendor\.pri\)")
  for projectName in ${packages}; do
    echo "* ${projectName}"
    local res=0

    ## Git package
    if [ -d "${vendorDir}/${projectName}/.git" ]; then
      logDebug "  Export Git package"
      local remoteGitPath
      local remoteGitRelativePath
      remoteGitPath="${REPO_PATH}/$(getOnePackageNameFromLock "${qompoterLockFile}" "${projectName}")/${projectName}.git"
      # Existing remote Git package: push new version
      if [ -d "${remoteGitPath}" ]; then
        cd "${vendorDir}/${projectName}" || ( echo "  Error: cannot go to !$" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
        remoteGitRelativePath=$(pwd)
        logDebug "  Clean package in vendor"
        logTrace "git gc"
        git gc >> ${C_LOG_FILENAME} 2>&1
        logGitTrace $(cat "${C_LOG_FILENAME}")
        # Git remote not already set
        logTrace "git remote -v"
        logGitTrace $(git remote -v)
        if [[ -z $(git remote -v | grep "${remoteGitRelativePath}") ]]; then
          if [[ ! -z $(git remote -v | grep "qompoter") ]]; then
            logDebug "  Change \"qompoter\" remote to \"${remoteGitRelativePath}\""
            logTrace "git remote set-url qompoter "${remoteGitRelativePath}""
            git remote set-url qompoter "${remoteGitRelativePath}" >> ${C_LOG_FILENAME} 2>&1 \
              || res=1
          else
            logDebug "  Add \"${remoteGitRelativePath}\" as \"qompoter\" remote"
            logTrace "git remote add qompoter "${remoteGitRelativePath}""
            git remote add qompoter "${remoteGitRelativePath}" >> ${C_LOG_FILENAME} 2>&1 \
              || res=1
          fi
        fi
        logDebug "  Push to remote ${remoteGitPath}"
        git push qompoter --all > ${C_LOG_FILENAME} 2>&1 \
          || res=1
        logGitTrace $(cat "${C_LOG_FILENAME}")
        cd - > /dev/null 2>&1 || ( echo "  Error: cannot go to !$" ; echo -e "${C_FAIL}FAILURE${C_END}" ; exit -1)
      # Not remote git package: clone --bare
      else
        logDebug "  Clone to remote ${remoteGitPath}"
        git clone --bare "${vendorDir}/${projectName}" "${remoteGitPath}" >> ${C_LOG_FILENAME} 2>&1 \
          || res=1 \
        logGitTrace $(cat "${C_LOG_FILENAME}")
      fi

    ## Version or something else
    else
      logDebug "  Export source package"
      local remotePath
      remotePath="${REPO_PATH}/$(getOnePackageFullNameFromLock "${qompoterLockFile}" "${projectName}")"
      # Not available or rrror in lock file: warning and ignore
      if [ "${remotePath}" == "${REPO_PATH}/" ]; then
        logWarning "\"${projectName}\" has not been found in lock file"
        res=1
      else
        # First export of this package: create dir
        if [ ! -d "${remotePath}" ]; then
          logDebug "  Create remote dir \"${remotePath}\""
          mkdir -p "${remotePath}"
        fi
        logDebug "  Copy package files to ${remotePath}"
        cp -rf ${vendorDir}/${projectName}/* "${remotePath}" \
          || res=1
        logDebug "  Copy any package libraries to ${remotePath}"
        # FIXME Check rsync error
        rsync -avR ${vendorDir}/./lib_*/*${projectName}* "${remotePath}" >> ${C_LOG_FILENAME} 2>&1
      fi
    fi

    if [ "$res" != "0" ]; then
      if [ "${IS_BYPASS}" == "1" ]; then
        echo -e "  ${C_SKIP}SKIPPED${C_END}"
        echo
      else
        echo -e "  ${C_FAIL}FAILURE${C_END}"
        echo
      fi
      test "${IS_BYPASS}" == "0" && test "${IS_FORCE}" == "0" && return 1
    else
      echo -e "  ${C_OK}done${C_END}"
      echo
    fi
  done

  ## Generate tarbal
  local repositoryBackup=`date +"%Y-%m-%d"`_`getProjectName ${qompoterFile}`_repository.tar.gz
  if [ -f "${repositoryBackup}" ]; then
    rm ${repositoryBackup}
  fi
  if [ -d "${REPO_PATH}" ]; then
    logDebug "Generate tarball"
    local currentPath=`pwd`
    (cd ${REPO_PATH} ; tar czf ${currentPath}/${repositoryBackup} *)
    if [ "$?" == "0" ]; then
      echo "Exported to ${REPO_PATH}"
      return 0
    else
      echo "Cannot generate the tarball"
    fi
  fi
  return 1
}

# destFile line newText
insertAfter()
{
   local file="$1"
   local line="$2"
   local newText="$3"
   # sed -i not supported by Solaris
   sed -i -e "/$line$/a"$'\\\n'"$newText"$'\n' "${file}"
   # sed -e "/$line$/a"$'\\\n'"$newText"$'\n' "$file" > "$file".tmp && mv "$file".tmp "$file"
   # Use following to match exact line
   # sed -e "/^$line$/a"$'\\\n'"$newText"$'\n' "$file" > "$file".tmp && mv "$file".tmp "$file"
}

# destFile patternLine file
insertFileAfterLine()
{
  local destFile="$1"
  local line="$2"
  local file="$3"
  sed -i -e "/$line$/r ${file}" "${destFile}"
}

replaceLineByFile()
{
  local destFile="$1"
  local line="$2"
  local file="$3"
  sed -i -e "/$line$/r ${file}" "${destFile}"
  removeLine "${destFile}" "${line}"
}

# destFile oldLine newLine
replaceLine()
{
   local file="$1"
   local oldLine="$2"
   local newLine="$3"
   # sed -i not supported by Solaris
   sed -i -e "s/${oldLine}/${newLine}/" "${file}"
}

replaceBlock()
{
   local file="$1"
   local oldBlock="$2"
   local newBlock="$3"
   # sed multiline @see http://austinmatzko.com/2008/04/26/sed-multi-line-search-and-replace/
   # In case of issue use instead: cat "${file}" | tr '\n' '|' | sed -e "s/${oldBlock}/${newBlock}/" | tr '|' '\n' > "${file}"
   # sed -i not supported by Solaris
   sed -i -n '1h;1!H;${;g;s/\n'"${oldBlock}"'/'"${newBlock}"'/g;p;}' "${file}"
}

removeLine()
{
   local file="$1"
   local line="$2"
   # sed -i not supported by Solaris
   sed -i "/${line}/d" "${file}"
}

removeBlock()
{
   local file="$1"
   local block="$2"
   # sed multiline @see http://austinmatzko.com/2008/04/26/sed-multi-line-search-and-replace/
   # In case of issue use instead: cat "${file}" | tr '\n' '@@@' | sed -e "s/${block}//" | tr '@' '\n' > "${file}"
   # sed -i not supported by Solaris
   sed -i -n '1h;1!H;${;g;s/\n'"${block}"'//g;p;}' "${file}"
}

logWarning()
{
  echo "  Warning: $@"
}

logDebug()
{
  if [ "$IS_VERBOSE" == "1" ] || [ "$IS_VERBOSE" == "2" ] || [ "$IS_VERBOSE" == "3" ]; then
    echo "$@"
  fi
}

logTrace()
{
  if [ "$IS_VERBOSE" == "2" ] || [ "$IS_VERBOSE" == "3" ]; then
    echo "    $@"
  fi
}

logGitTrace()
{
  if [ "$IS_VERBOSE" == "3" ]; then
    echo "      $@"
  fi
}

cmdline()
{
  ACTION=
  SUB_ACTION=

  if [ "$#" -lt "1" ]; then
    echo -e "${C_FAIL}FAILURE${C_END} missing arguments"
    usage
    exit -1
  fi
  while [ "$1" != "" ]; do
  case $1 in
    --all )
      if [ "${ACTION}" == "inspect"  ]; then
        IS_ALL=1
      else
        echo "Ignore flag --all for action '${ACTION}'"
      fi
      shift
    ;;
    --by-pass )
      IS_BYPASS=1
      shift
      ;;
    -d | --depth )
      shift
      DEPTH_SIZE=$1
      shift
      ;;
    --file )
      shift
      QOMPOTER_FILENAME=$1
      NEW_SUBPACKAGES=${QOMPOTER_FILENAME}
      shift
      ;;
    --inqlude-file )
      shift
      INQLUDE_FILENAME=$1
      shift
      ;;
    -f | --force )
      IS_FORCE=1
      shift
      ;;
    --no-color )
      C_OK=
      C_FAIL=
      C_END=
      shift
      ;;
    --no-dev )
      IS_INCLUDE_DEV=
      shift
      ;;
    --no-dep )
      DEPTH_SIZE=0
      shift
      ;;
    --no-qompote  )
      IS_NO_QOMPOTE=1
      shift
      ;;
    --stable-only )
      IS_STABLE_ONLY=1
      shift
      ;;
    -r | --repo )
      shift
      REPO_PATH=$1
      shift
      if [ "${ACTION}" == "export"  ]; then
        SUB_ACTION="repo"
      fi
      ;;
    --vendor-dir )
      shift
      VENDOR_DIR=$1
      shift
      ;;
    -V | --verbose )
      IS_VERBOSE=1
      shift
      ;;
    -VV )
      IS_VERBOSE=2
      shift
      ;;
    -VVV )
      IS_VERBOSE=3
      shift
      ;;
    -h | --help )
      usage
      exit 0
      ;;
    -v | --version )
      version
      exit 0
      ;;
    --list )
      if [ "${ACTION}" == "require"  ]; then
        SUB_ACTION="list"
      else
        echo "Ignore flag --list for action '${ACTION}'"
      fi
      shift
    ;;
    --minify )
      if [ "${ACTION}" == "inqlude"  ]; then
        SUB_ACTION="minify"
      else
        echo "Ignore flag --minify for action '${ACTION}'"
      fi
      shift
    ;;
    --search )
      if [ "${ACTION}" == "inqlude"  ]; then
        SUB_ACTION="search"
      else
        echo "Ignore flag --search for action '${ACTION}'"
      fi
      shift
    ;;
    *)
      if [ "${ACTION}" == ""  ]; then
        ACTION=$1
        shift
      elif [ "${ACTION}" == "inqlude"  ] || [ "${ACTION}" == "init" ] || [ "${ACTION}" == "install" ]; then
        if [ "${VENDOR_NAME}" == ""  ]; then
          VENDOR_NAME=$(echo "${1}" | cut -d'/' -f1)
          PROJECT_NAME=$(echo "${1}" | cut -d'/' -f2)
          shift
        elif [ "${PACKAGE_VERSION}" == ""  ]; then
          PACKAGE_VERSION=$1
          shift
        else
          echo -e "${C_FAIL}FAILURE${C_END} unknown argument '$1'"
          usage
          exit -1
        fi
      elif [ "${ACTION}" == "md5sum" ] && [ "${VENDOR_NAME}" == ""  ]; then
        VENDOR_NAME=$1
        shift
      else
        echo -e "${C_FAIL}FAILURE${C_END} unknown argument '$1'"
        usage
        exit -1
      fi
      ;;
  esac
  done

  # Aliases
  if [ "${ACTION}" == "e"  ]; then
    ACTION="export"
  elif [ "${ACTION}" == "i"  ]; then
    ACTION="install"
  elif [ "${ACTION}" == "u"  ]; then
    ACTION="update"
  fi

  # Specific usage
  if [[ "${ACTION}" == "init" ]] && [[ ${PROJECT_NAME} == "" ]]; then
    echo -e "${C_FAIL}FAILURE${C_END} missing parameters for action '${ACTION}'"
    echo "Usage: $C_PROGNAME ${ACTION} <vendor/packagename> [<version>]"
    exit -1
  elif [[ "${ACTION}" == "inqlude" ]]; then
    if [[ ${SUB_ACTION} == "" ]]; then
      echo -e "${C_FAIL}FAILURE${C_END} missing subaction 'search' or 'minify' for action '${ACTION}'"
      echo "Usage: $C_PROGNAME ${ACTION} [ --minify | --search <vendor/packagename> <version> ]"
      exit -1
    elif [[ "${ACTION}" == "inqlude" ]] && [[ ${SUB_ACTION} == "search" ]] && [[ ${PROJECT_NAME} == "" ]]; then
      echo -e "${C_FAIL}FAILURE${C_END} missing parameters for action '${ACTION}'"
      echo "Usage: $C_PROGNAME ${ACTION} [ --minify | --search <vendor/packagename> <version> ]"
      exit -1
    fi
  elif [[ "${ACTION}" == "md5sum" ]] && [[ ${VENDOR_NAME} == "" ]]; then
    echo -e "${C_FAIL}FAILURE${C_END} missing dir name for action '${ACTION}'"
    echo "Usage: $C_PROGNAME ${ACTION} <dir>"
    exit -1
  fi

  if [ "${ACTION}" == ""  ]; then
    echo -e "${C_FAIL}FAILURE${C_END} missing action"
    usage
    exit -1
  fi

  return 0
}

main()
{
  cmdline $C_ARGS
  if [ -f "${C_LOG_FILENAME}" ]; then
    rm ${C_LOG_FILENAME}
  fi
  touch ${C_LOG_FILENAME}

  echo "Qompoter"
  echo "======== ${ACTION}"
  echo

  updateVendorDirFromQompoterFile "${QOMPOTER_FILENAME}"
  case ${ACTION} in
    "export")
      if [ "${SUB_ACTION}" == "repo" ]; then
        repoExportAction "${QOMPOTER_FILENAME}" "${VENDOR_DIR}"
      else
        exportAction "${QOMPOTER_FILENAME}" "${VENDOR_DIR}"
      fi
      ;;
    "init")
      initAction "${VENDOR_NAME}" "${PROJECT_NAME}" "${PACKAGE_VERSION}" "${QOMPOTER_FILENAME}"
      ;;
    "inqlude")
      if [ "${SUB_ACTION}" == "search" ]; then
        inqludeSearchAction "${VENDOR_NAME}" "${PROJECT_NAME}" "${PACKAGE_VERSION}" "${INQLUDE_FILENAME}"
      elif [ "${SUB_ACTION}" == "minify" ]; then
        inqludeMinifyAction "${INQLUDE_FILENAME}"
      fi
      ;;
    "inspect")
      inspectAction "${QOMPOTER_FILENAME}" "${VENDOR_DIR}"
      ;;
    "install")
      if [ -z "${PROJECT_NAME}" ]; then
        installAction "${QOMPOTER_FILENAME}" "${VENDOR_DIR}"
      else
        installOnePackageAction "${QOMPOTER_FILENAME}" "${VENDOR_DIR}" "${VENDOR_NAME}" "${PROJECT_NAME}" "${PACKAGE_VERSION}"
      fi
      ;;
    "jsonh")
      jsonhAction "${QOMPOTER_FILENAME}"
      ;;
    "md5sum")
      md5sumAction "${VENDOR_NAME}"
      ;;
    "require")
      if [ "${SUB_ACTION}" == "list" ]; then
        requireListAction "${QOMPOTER_FILENAME}"
      else
        requireAction "${QOMPOTER_FILENAME}"
      fi
      ;;
    "update")
      updateAction "${QOMPOTER_FILENAME}" "${VENDOR_DIR}"
      ;;
    *)
      echo -e "${C_FAIL}FAILURE${C_END} Unknown action '${ACTION}'"
      return 1
      ;;
  esac
  local status=$?

  if [ "$IS_VERBOSE" == "0" ]; then
    rm ${C_LOG_FILENAME}
  fi

  if [ "$status" != "0" ]; then
    echo -e "${C_FAIL}FAILURE${C_END}"
    return 1
  else
    echo -e "${C_OK}done${C_END}"
    return 0
  fi
}

INQLUDE_ALL_CONTENT_LAST_UPDATE='2016-09-09'
INQLUDE_ALL_MIN_CONTENT='[0,"name"]	"adctl"
[0,"display_name"]	"AdCtl"
[0,"version"]	"0.1.1"
[0,"summary"]	"Google Play Auth, Achives and Ratings, AdMob, and Analytics for Qt/QML on Android/iOS"
[0,"urls","vcs"]	"https://github.com/kafeg/adctl.git"
[0,"licenses"]	["Modified BSD"]
[0,"maturity"]	"alpha"
[0,"platforms"]	["Android","iOS"]
[0,"packages","source"]	"https://github.com/kafeg/adctl/archive/qpm/0.1.1.tar.gz"
[1,"name"]	"attica"
[1,"display_name"]	"Attica"
[1,"version"]	"5.25.0"
[1,"summary"]	"Open Collaboration Services API"
[1,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/attica/repository"
[1,"licenses"]	["LGPLv2.1+"]
[1,"maturity"]	"stable"
[1,"platforms"]	["Linux"]
[1,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/attica-5.25.0.tar.xz"
[2,"name"]	"avahi-qt"
[2,"display_name"]	"Avahi"
[2,"version"]	"0.6.32"
[2,"summary"]	"Qt4 Bindings for avahi, the D-BUS Service for Zeroconf and Bonjour"
[2,"urls","vcs"]	"https://github.com/lathiat/avahi"
[2,"licenses"]	["LGPLv2.1+"]
[2,"maturity"]	"stable"
[2,"platforms"]	["Linux"]
[2,"packages","source"]	"https://github.com/lathiat/avahi/releases/download/v0.6.32/avahi-0.6.32.tar.gz"
[3,"name"]	"baloo"
[3,"display_name"]	"Baloo"
[3,"version"]	"5.25.0"
[3,"summary"]	"Baloo is a file indexing and searching framework"
[3,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/baloo/repository"
[3,"licenses"]	["LGPLv2.1+"]
[3,"maturity"]	"stable"
[3,"platforms"]	["Linux"]
[3,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/baloo-5.25.0.tar.xz"
[4,"name"]	"bluez-qt"
[4,"display_name"]	"BluezQt"
[4,"version"]	"5.25.0"
[4,"summary"]	"Qt wrapper for BlueZ 5 DBus API"
[4,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/bluez-qt/repository"
[4,"licenses"]	["LGPLv2.1+"]
[4,"maturity"]	"stable"
[4,"platforms"]	["Linux"]
[4,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/bluez-qt-5.25.0.tar.xz"
[5,"name"]	"breeze-icons"
[5,"display_name"]	"Breeze Icons"
[5,"version"]	"5.25.0"
[5,"summary"]	"Breeze icon theme"
[5,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/breeze-icons/repository"
[5,"licenses"]	["LGPLv2.1+"]
[5,"maturity"]	"stable"
[5,"platforms"]	["Linux"]
[5,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/breeze-icons-5.25.0.tar.xz"
[6,"name"]	"ctk"
[6,"summary"]	"Toolkit for biomedical image computing"
[6,"urls","vcs"]	"http://github.com/commontk/CTK"
[6,"licenses"]	["Apache-2.0"]
[6,"platforms"]	["Linux"]
[7,"name"]	"cutelyst"
[7,"version"]	"0.5.0"
[7,"summary"]	"A Web Framework, using the simple approach of Catalyst (Perl) framework."
[7,"urls","vcs"]	"https://gitorious.org/cutelyst/cutelyst.git"
[7,"licenses"]	["LGPLv2"]
[7,"maturity"]	"edge"
[7,"platforms"]	["Linux","Windows","OS X"]
[7,"packages","source"]	"https://gitorious.org/cutelyst/cutelyst/archive/c77510285823c87b20726e40cda1ec7247d91966.tar.gz"
[8,"name"]	"cutereport"
[8,"display_name"]	"CuteReport"
[8,"version"]	"1.2"
[8,"summary"]	"Report solution"
[8,"urls","vcs"]	""
[8,"licenses"]	["GPLv3+","Commercial"]
[8,"maturity"]	"stable"
[8,"platforms"]	["Linux","Windows","OS X"]
[8,"packages","source"]	"https://cute-report.com/en/download/94"
[9,"name"]	"cutetest"
[9,"summary"]	"Unit testing for Qt"
[9,"urls","vcs"]	"https://bitbucket.org/mayastudios/cutetest/src"
[9,"licenses"]	["LGPLv3+","BSD-3-clause","Apache-2.0"]
[9,"platforms"]	["Linux","Windows","OS X"]
[10,"name"]	"diff-match-patch"
[10,"display_name"]	"google-diff-match-patch"
[10,"version"]	"20121119"
[10,"summary"]	"Diff, Match and Patch libraries for Plain Text"
[10,"urls","vcs"]	"http://code.google.com/p/google-diff-match-patch/source/browse/"
[10,"licenses"]	["Apache2.0"]
[10,"maturity"]	"stable"
[10,"platforms"]	["Linux"]
[10,"packages","source"]	"https://google-diff-match-patch.googlecode.com/files/diff_match_patch_20121119.zip"
[11,"name"]	"echonest"
[11,"version"]	"2.1.0"
[11,"summary"]	"Qt library for communicating with The Echo Nest"
[11,"urls","vcs"]	"https://projects.kde.org/projects/playground/libs/libechonest/repository"
[11,"licenses"]	["LGPL"]
[11,"maturity"]	"stable"
[11,"platforms"]	["Linux"]
[11,"packages","source"]	"http://files.lfranchi.com/libechonest-2.1.0.tar.bz2"
[12,"name"]	"enginio-qt"
[12,"version"]	"0.5.0"
[12,"summary"]	"Enginio client library for Qt platfom. Provides both Qt C++ and QML APIs to client applications."
[12,"urls","vcs"]	"https://github.com/enginio/enginio-qt"
[12,"licenses"]	["GPLv3","LGPLv2.1"]
[12,"maturity"]	"stable"
[12,"platforms"]	["Linux","Windos","OS X"]
[12,"packages","source"]	"https://github.com/enginio/enginio-qt/archive/0.5.0.tar.gz"
[13,"name"]	"exaro"
[13,"version"]	"2.0.0"
[13,"summary"]	"Report engine"
[13,"urls","vcs"]	"http://code.google.com/p/exaro/source/browse"
[13,"licenses"]	["GPLv3","LGPLv3"]
[13,"maturity"]	"stable"
[13,"platforms"]	["Linux","Windows"]
[13,"packages","source"]	"http://sourceforge.net/projects/exaro/files/exaro/exaro%202.0.0/exaro_2.0.0.tar.lzma/download"
[14,"name"]	"extra-cmake-modules"
[14,"version"]	"5.25.0"
[14,"summary"]	"Extensions for software using the CMake build system"
[14,"urls","vcs"]	"https://projects.kde.org/projects/kdesupport/extra-cmake-modules/repository"
[14,"licenses"]	["BSD-3-Clause"]
[14,"maturity"]	"stable"
[14,"platforms"]	["Linux","OS X","Windows"]
[14,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/extra-cmake-modules-5.25.0.tar.xz"
[15,"name"]	"ff7tk"
[15,"summary"]	"Toolkit for working with data from Final Fantasy 7"
[15,"urls","vcs"]	"https://github.com/sithlord48/ff7tk/"
[15,"licenses"]	["GPLv3+"]
[15,"platforms"]	["Linux","Windows","MacOs","Android"]
[16,"name"]	"frameworkintegration"
[16,"display_name"]	"Framework Integration"
[16,"version"]	"5.25.0"
[16,"summary"]	"Workspace and cross-framework integration plugins"
[16,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/frameworkintegration/repository"
[16,"licenses"]	["LGPLv2.1+"]
[16,"maturity"]	"stable"
[16,"platforms"]	["Linux"]
[16,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/frameworkintegration-5.25.0.tar.xz"
[17,"name"]	"gcf"
[17,"version"]	"2.6.0"
[17,"summary"]	"Generic component framework"
[17,"urls","vcs"]	"http://code.vcreatelogic.com:8045/GCF2/trunk/GCF"
[17,"licenses"]	["GPLv2","GPLv3","Commercial"]
[17,"maturity"]	"stable"
[17,"platforms"]	["Linux","Windows"]
[17,"packages","source"]	"http://www.vcreatelogic.com/downloads/files/GCF-2.6.0-GPL-Source.7z"
[18,"name"]	"glc-lib"
[18,"version"]	"2.5.2"
[18,"summary"]	"Library for high performance 3D applications based on OpenGL"
[18,"urls","vcs"]	"https://github.com/laumaya/GLC_lib"
[18,"licenses"]	["LGPLv3+"]
[18,"maturity"]	"stable"
[18,"platforms"]	["Linux","Windows","OS X"]
[18,"packages","source"]	"https://github.com/laumaya/GLC_lib/archive/Version_2_5_2.tar.gz"
[19,"name"]	"injeqt"
[19,"display_name"]	"injeqt"
[19,"version"]	"1.0.1"
[19,"summary"]	"Dependency injection"
[19,"urls","vcs"]	"https://github.com/vogel/injeqt"
[19,"licenses"]	["LGPLv2.1"]
[19,"maturity"]	"stable"
[19,"platforms"]	["Linux","Windows","OS X"]
[19,"packages","source"]	"https://github.com/vogel/injeqt/archive/1.0.1.tar.gz"
[20,"name"]	"jreen"
[20,"version"]	"1.1.1"
[20,"summary"]	"XMPP client library"
[20,"urls","vcs"]	"https://github.com/euroelessar/jreen"
[20,"licenses"]	["GPLv2+"]
[20,"maturity"]	"stable"
[20,"platforms"]	["Cross-platform"]
[20,"packages","source"]	"http://qutim.org/dwnl/44/libjreen-1.1.1.tar.bz2"
[21,"name"]	"kactivities"
[21,"display_name"]	"KActivities"
[21,"version"]	"5.25.0"
[21,"summary"]	"Runtime and library to organize the user work in separate activities"
[21,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kactivities/repository"
[21,"licenses"]	["LGPLv2.1+"]
[21,"maturity"]	"stable"
[21,"platforms"]	["Linux"]
[21,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kactivities-5.25.0.tar.xz"
[22,"name"]	"kactivities-stats"
[22,"display_name"]	"KActivitiesStats"
[22,"version"]	"5.25.0"
[22,"summary"]	"A library for accessing the usage data collected by the activities system."
[22,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kactivities-stats/repository"
[22,"licenses"]	["LGPLv2.1+"]
[22,"maturity"]	"stable"
[22,"platforms"]	["Linux"]
[22,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kactivities-stats-5.25.0.tar.xz"
[23,"name"]	"karchive"
[23,"display_name"]	"KArchive"
[23,"version"]	"5.25.0"
[23,"summary"]	"File compression"
[23,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/karchive/repository"
[23,"licenses"]	["LGPLv2.1+"]
[23,"maturity"]	"stable"
[23,"platforms"]	["Linux"]
[23,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/karchive-5.25.0.tar.xz"
[24,"name"]	"kauth"
[24,"display_name"]	"KAuth"
[24,"version"]	"5.25.0"
[24,"summary"]	"Abstraction to system policy and authentication features"
[24,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kauth/repository"
[24,"licenses"]	["LGPLv2.1+"]
[24,"maturity"]	"stable"
[24,"platforms"]	["Linux"]
[24,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kauth-5.25.0.tar.xz"
[25,"name"]	"kbookmarks"
[25,"display_name"]	"KBookmarks"
[25,"version"]	"5.25.0"
[25,"summary"]	"Support for bookmarks and the XBEL format"
[25,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kbookmarks/repository"
[25,"licenses"]	["LGPLv2.1+"]
[25,"maturity"]	"stable"
[25,"platforms"]	["Linux"]
[25,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kbookmarks-5.25.0.tar.xz"
[26,"name"]	"kcmutils"
[26,"display_name"]	"KCMUtils"
[26,"version"]	"5.25.0"
[26,"summary"]	"Utilities for working with KCModules"
[26,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kcmutils/repository"
[26,"licenses"]	["LGPLv2.1+"]
[26,"maturity"]	"stable"
[26,"platforms"]	["Linux"]
[26,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kcmutils-5.25.0.tar.xz"
[27,"name"]	"kcodecs"
[27,"display_name"]	"KCodecs"
[27,"version"]	"5.25.0"
[27,"summary"]	"Text encoding"
[27,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kcodecs/repository"
[27,"licenses"]	["LGPLv2.1+"]
[27,"maturity"]	"stable"
[27,"platforms"]	["Linux"]
[27,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kcodecs-5.25.0.tar.xz"
[28,"name"]	"kcompletion"
[28,"display_name"]	"KCompletion"
[28,"version"]	"5.25.0"
[28,"summary"]	"Text completion helpers and widgets"
[28,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kcompletion/repository"
[28,"licenses"]	["LGPLv2.1+"]
[28,"maturity"]	"stable"
[28,"platforms"]	["Linux"]
[28,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kcompletion-5.25.0.tar.xz"
[29,"name"]	"kconfig"
[29,"display_name"]	"KConfig"
[29,"version"]	"5.25.0"
[29,"summary"]	"Configuration system"
[29,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kconfig/repository"
[29,"licenses"]	["LGPLv2.1+"]
[29,"maturity"]	"stable"
[29,"platforms"]	["Linux"]
[29,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kconfig-5.25.0.tar.xz"
[30,"name"]	"kconfigwidgets"
[30,"display_name"]	"KConfigWidgets"
[30,"version"]	"5.25.0"
[30,"summary"]	"Widgets for configuration dialogs"
[30,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kconfigwidgets/repository"
[30,"licenses"]	["LGPLv2.1+"]
[30,"maturity"]	"stable"
[30,"platforms"]	["Linux"]
[30,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kconfigwidgets-5.25.0.tar.xz"
[31,"name"]	"kcoreaddons"
[31,"display_name"]	"KCoreAddons"
[31,"version"]	"5.25.0"
[31,"summary"]	"Addons to QtCore"
[31,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kcoreaddons/repository"
[31,"licenses"]	["LGPLv2.1+"]
[31,"maturity"]	"stable"
[31,"platforms"]	["Linux"]
[31,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kcoreaddons-5.25.0.tar.xz"
[32,"name"]	"kcrash"
[32,"display_name"]	"KCrash"
[32,"version"]	"5.25.0"
[32,"summary"]	"Support for application crash analysis and bug report from apps"
[32,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kcrash/repository"
[32,"licenses"]	["LGPLv2.1+"]
[32,"maturity"]	"stable"
[32,"platforms"]	["Linux"]
[32,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kcrash-5.25.0.tar.xz"
[33,"name"]	"kdbusaddons"
[33,"display_name"]	"KDBusAddons"
[33,"version"]	"5.25.0"
[33,"summary"]	"Addons to QtDBus"
[33,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kdbusaddons/repository"
[33,"licenses"]	["LGPLv2.1+"]
[33,"maturity"]	"stable"
[33,"platforms"]	["Linux"]
[33,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kdbusaddons-5.25.0.tar.xz"
[34,"name"]	"kdchart"
[34,"summary"]	"Creation of business charts"
[34,"licenses"]	["Commercial"]
[34,"maturity"]	"stable"
[34,"platforms"]	["Linux","Windows","OS X"]
[35,"name"]	"kdeclarative"
[35,"display_name"]	"KDeclarative"
[35,"version"]	"5.25.0"
[35,"summary"]	"Provides integration of QML and KDE Frameworks"
[35,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kdeclarative/repository"
[35,"licenses"]	["LGPLv2.1+"]
[35,"maturity"]	"stable"
[35,"platforms"]	["Linux"]
[35,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kdeclarative-5.25.0.tar.xz"
[36,"name"]	"kded"
[36,"display_name"]	"KDED"
[36,"version"]	"5.25.0"
[36,"summary"]	"Extensible deamon for providing system level services"
[36,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kded/repository"
[36,"licenses"]	["LGPLv2.1+"]
[36,"maturity"]	"stable"
[36,"platforms"]	["Linux"]
[36,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kded-5.25.0.tar.xz"
[37,"name"]	"kdelibs"
[37,"version"]	"4.11.1"
[37,"summary"]	"KDE Development Platform"
[37,"urls","vcs"]	"https://projects.kde.org/projects/kde/kdelibs/repository"
[37,"licenses"]	["LGPLv2.1+"]
[37,"maturity"]	"stable"
[37,"platforms"]	["Linux","Windows","MacOS"]
[37,"packages","source"]	"http://download.kde.org/stable/4.11.1/src/kdelibs-4.11.1.tar.xz"
[38,"name"]	"kdelibs4support"
[38,"display_name"]	"KDELibs 4 Support"
[38,"version"]	"5.25.0"
[38,"summary"]	"Porting aid from KDELibs4"
[38,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kdelibs4support/repository"
[38,"licenses"]	["LGPLv2.1+"]
[38,"maturity"]	"stable"
[38,"platforms"]	["Linux"]
[38,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kdelibs4support-5.25.0.tar.xz"
[39,"name"]	"kdepimlibs"
[39,"version"]	"4.11.1"
[39,"summary"]	"KDE PIM Libraries"
[39,"urls","vcs"]	"https://projects.kde.org/projects/kde/kdepimlibs/repository"
[39,"licenses"]	["LGPLv2.1+"]
[39,"maturity"]	"stable"
[39,"platforms"]	["Linux","Windows","MacOS"]
[39,"packages","source"]	"http://download.kde.org/stable/4.11.1/src/kdepimlibs-4.11.1.tar.xz"
[40,"name"]	"kdesignerplugin"
[40,"display_name"]	"KDesignerPlugin"
[40,"version"]	"5.25.0"
[40,"summary"]	"Integration of Frameworks widgets in Qt Designer/Creator"
[40,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kdesignerplugin/repository"
[40,"licenses"]	["LGPLv2.1+"]
[40,"maturity"]	"stable"
[40,"platforms"]	["Linux"]
[40,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kdesignerplugin-5.25.0.tar.xz"
[41,"name"]	"kdesu"
[41,"display_name"]	"KDESU"
[41,"version"]	"5.25.0"
[41,"summary"]	"Integration with su for elevated privileges"
[41,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kdesu/repository"
[41,"licenses"]	["LGPLv2.1+"]
[41,"maturity"]	"stable"
[41,"platforms"]	["Linux"]
[41,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kdesu-5.25.0.tar.xz"
[42,"name"]	"kdewebkit"
[42,"display_name"]	"KDE WebKit"
[42,"version"]	"5.25.0"
[42,"summary"]	"KDE Integration for QtWebKit"
[42,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kdewebkit/repository"
[42,"licenses"]	["LGPLv2.1+"]
[42,"maturity"]	"stable"
[42,"platforms"]	["Linux"]
[42,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kdewebkit-5.25.0.tar.xz"
[43,"name"]	"kdnssd"
[43,"display_name"]	"KDE DNS-SD"
[43,"version"]	"5.25.0"
[43,"summary"]	"Abstraction to system DNSSD features"
[43,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kdnssd/repository"
[43,"licenses"]	["LGPLv2.1+"]
[43,"maturity"]	"stable"
[43,"platforms"]	["Linux"]
[43,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kdnssd-5.25.0.tar.xz"
[44,"name"]	"kdoctools"
[44,"display_name"]	"KDocTools"
[44,"version"]	"5.25.0"
[44,"summary"]	"Documentation generation from docbook"
[44,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kdoctools/repository"
[44,"licenses"]	["LGPLv2.1+"]
[44,"maturity"]	"stable"
[44,"platforms"]	["Linux"]
[44,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kdoctools-5.25.0.tar.xz"
[45,"name"]	"kdreports"
[45,"version"]	"1.5.0"
[45,"summary"]	"Report generator"
[45,"urls","vcs"]	"https://github.com/KDAB/KDReports"
[45,"licenses"]	["LGPLv2.1+","Commercial"]
[45,"maturity"]	"stable"
[45,"platforms"]	["Linux","Windows","OS X"]
[46,"name"]	"kdsoap"
[46,"version"]	"1.3.0"
[46,"summary"]	"Client-side and server-side SOAP component"
[46,"urls","vcs"]	"https://github.com/KDAB/KDSoap"
[46,"licenses"]	["LGPLv2.1+","Commercial"]
[46,"maturity"]	"stable"
[46,"platforms"]	["Linux","Windows","OS X"]
[46,"packages","source"]	"https://github.com/KDAB/KDSoap/archive/kdsoap-1.3.0.tar.gz"
[47,"name"]	"kdtools"
[47,"summary"]	"Productivity tools"
[47,"licenses"]	["Commercial"]
[47,"maturity"]	"stable"
[47,"platforms"]	["Linux","Windows","OS X"]
[48,"name"]	"kemoticons"
[48,"display_name"]	"KEmoticons"
[48,"version"]	"5.25.0"
[48,"summary"]	"Support for emoticons and emoticons themes"
[48,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kemoticons/repository"
[48,"licenses"]	["LGPLv2.1+"]
[48,"maturity"]	"stable"
[48,"platforms"]	["Linux"]
[48,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kemoticons-5.25.0.tar.xz"
[49,"name"]	"kf5umbrella"
[49,"display_name"]	"KF5Umbrella"
[49,"version"]	"5.25.0"
[49,"summary"]	"CMake convenience functions for KDE Frameworks"
[49,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kf5umbrella/repository"
[49,"licenses"]	["LGPLv2.1+"]
[49,"maturity"]	"stable"
[49,"platforms"]	["Linux"]
[49,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kf5umbrella-5.25.0.tar.xz"
[50,"name"]	"kfileaudiopreview"
[50,"display_name"]	"KFileAudioPreview"
[50,"version"]	"5.25.0"
[50,"summary"]	"Preview of audio files"
[50,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kfileaudiopreview/repository"
[50,"licenses"]	["LGPLv2.1+"]
[50,"maturity"]	"stable"
[50,"platforms"]	["Linux"]
[50,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kfileaudiopreview-5.25.0.tar.xz"
[51,"name"]	"kfilemetadata"
[51,"display_name"]	"KFileMetaData"
[51,"version"]	"5.25.0"
[51,"summary"]	"A file metadata and text extraction library"
[51,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kfilemetadata/repository"
[51,"licenses"]	["LGPLv2.1+"]
[51,"maturity"]	"stable"
[51,"platforms"]	["Linux"]
[51,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kfilemetadata-5.25.0.tar.xz"
[52,"name"]	"kglobalaccel"
[52,"display_name"]	"KGlobalAccel"
[52,"version"]	"5.25.0"
[52,"summary"]	"Add support for global workspace shortcuts"
[52,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kglobalaccel/repository"
[52,"licenses"]	["LGPLv2.1+"]
[52,"maturity"]	"stable"
[52,"platforms"]	["Linux"]
[52,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kglobalaccel-5.25.0.tar.xz"
[53,"name"]	"kguiaddons"
[53,"display_name"]	"KDE GUI Addons"
[53,"version"]	"5.25.0"
[53,"summary"]	"Addons to QtGui"
[53,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kguiaddons/repository"
[53,"licenses"]	["LGPLv2.1+"]
[53,"maturity"]	"stable"
[53,"platforms"]	["Linux"]
[53,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kguiaddons-5.25.0.tar.xz"
[54,"name"]	"khtml"
[54,"display_name"]	"KHTML"
[54,"version"]	"5.25.0"
[54,"summary"]	"KHTML APIs"
[54,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/khtml/repository"
[54,"licenses"]	["LGPLv2.1+"]
[54,"maturity"]	"stable"
[54,"platforms"]	["Linux"]
[54,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/khtml-5.25.0.tar.xz"
[55,"name"]	"ki18n"
[55,"display_name"]	"KI18n"
[55,"version"]	"5.25.0"
[55,"summary"]	"Advanced internationalization framework"
[55,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/ki18n/repository"
[55,"licenses"]	["LGPLv2.1+"]
[55,"maturity"]	"stable"
[55,"platforms"]	["Linux"]
[55,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/ki18n-5.25.0.tar.xz"
[56,"name"]	"kiconthemes"
[56,"display_name"]	"KIconThemes"
[56,"version"]	"5.25.0"
[56,"summary"]	"Support for icon themes"
[56,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kiconthemes/repository"
[56,"licenses"]	["LGPLv2.1+"]
[56,"maturity"]	"stable"
[56,"platforms"]	["Linux"]
[56,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kiconthemes-5.25.0.tar.xz"
[57,"name"]	"kidletime"
[57,"display_name"]	"KIdleTime"
[57,"version"]	"5.25.0"
[57,"summary"]	"Monitoring user activity"
[57,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kidletime/repository"
[57,"licenses"]	["LGPLv2.1+"]
[57,"maturity"]	"stable"
[57,"platforms"]	["Linux"]
[57,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kidletime-5.25.0.tar.xz"
[58,"name"]	"kimageformats"
[58,"display_name"]	"KImageFormats"
[58,"version"]	"5.25.0"
[58,"summary"]	"Image format plugins for Qt"
[58,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kimageformats/repository"
[58,"licenses"]	["LGPLv2.1+"]
[58,"maturity"]	"stable"
[58,"platforms"]	["Linux"]
[58,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kimageformats-5.25.0.tar.xz"
[59,"name"]	"kinit"
[59,"display_name"]	"KInit"
[59,"version"]	"5.25.0"
[59,"summary"]	"Process launcher to speed up launching KDE applications"
[59,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kinit/repository"
[59,"licenses"]	["LGPLv2.1+"]
[59,"maturity"]	"stable"
[59,"platforms"]	["Linux"]
[59,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kinit-5.25.0.tar.xz"
[60,"name"]	"kio"
[60,"display_name"]	"KIO"
[60,"version"]	"5.25.0"
[60,"summary"]	"Resource and network access abstraction"
[60,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kio/repository"
[60,"licenses"]	["LGPLv2.1+"]
[60,"maturity"]	"stable"
[60,"platforms"]	["Linux"]
[60,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kio-5.25.0.tar.xz"
[61,"name"]	"kitemmodels"
[61,"display_name"]	"KItemModels"
[61,"version"]	"5.25.0"
[61,"summary"]	"Models for Qt Model/View system"
[61,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kitemmodels/repository"
[61,"licenses"]	["LGPLv2.1+"]
[61,"maturity"]	"stable"
[61,"platforms"]	["Linux"]
[61,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kitemmodels-5.25.0.tar.xz"
[62,"name"]	"kitemviews"
[62,"display_name"]	"KItemViews"
[62,"version"]	"5.25.0"
[62,"summary"]	"Widget addons for Qt Model/View"
[62,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kitemviews/repository"
[62,"licenses"]	["LGPLv2.1+"]
[62,"maturity"]	"stable"
[62,"platforms"]	["Linux"]
[62,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kitemviews-5.25.0.tar.xz"
[63,"name"]	"kjobwidgets"
[63,"display_name"]	"KJobWidgets"
[63,"version"]	"5.25.0"
[63,"summary"]	"Widgets for tracking KJob instances"
[63,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kjobwidgets/repository"
[63,"licenses"]	["LGPLv2.1+"]
[63,"maturity"]	"stable"
[63,"platforms"]	["Linux"]
[63,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kjobwidgets-5.25.0.tar.xz"
[64,"name"]	"kjs"
[64,"display_name"]	"KJS"
[64,"version"]	"5.25.0"
[64,"summary"]	"Support for JS scripting in applications"
[64,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kjs/repository"
[64,"licenses"]	["LGPLv2.1+"]
[64,"maturity"]	"stable"
[64,"platforms"]	["Linux"]
[64,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kjs-5.25.0.tar.xz"
[65,"name"]	"kjsembed"
[65,"display_name"]	"KJSEmbed"
[65,"version"]	"5.25.0"
[65,"summary"]	"Embedded JS"
[65,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kjsembed/repository"
[65,"licenses"]	["LGPLv2.1+"]
[65,"maturity"]	"stable"
[65,"platforms"]	["Linux"]
[65,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kjsembed-5.25.0.tar.xz"
[66,"name"]	"klfbackend"
[66,"version"]	"3.2.7"
[66,"summary"]	"KLatexFormula backend library"
[66,"urls","vcs"]	"http://sourceforge.net/scm/?type=svn&group_id=174270"
[66,"licenses"]	["GPLv2+"]
[66,"maturity"]	"stable"
[66,"platforms"]	["Linux"]
[66,"packages","source"]	"http://sourceforge.net/projects/klatexformula/files/klatexformula/klatexformula-3.2.7/klatexformula-3.2.7.tar.gz/download"
[67,"name"]	"kmediaplayer"
[67,"display_name"]	"KMediaPlayer"
[67,"version"]	"5.25.0"
[67,"summary"]	"Plugin interface for media player features"
[67,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kmediaplayer/repository"
[67,"licenses"]	["LGPLv2.1+"]
[67,"maturity"]	"stable"
[67,"platforms"]	["Linux"]
[67,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kmediaplayer-5.25.0.tar.xz"
[68,"name"]	"knewstuff"
[68,"display_name"]	"KNewStuff"
[68,"version"]	"5.25.0"
[68,"summary"]	"Support for downloading application assets from the network"
[68,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/knewstuff/repository"
[68,"licenses"]	["LGPLv2.1+"]
[68,"maturity"]	"stable"
[68,"platforms"]	["Linux"]
[68,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/knewstuff-5.25.0.tar.xz"
[69,"name"]	"knotifications"
[69,"display_name"]	"KNotification"
[69,"version"]	"5.25.0"
[69,"summary"]	"Abstraction for system notifications"
[69,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/knotifications/repository"
[69,"licenses"]	["LGPLv2.1+"]
[69,"maturity"]	"stable"
[69,"platforms"]	["Linux"]
[69,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/knotifications-5.25.0.tar.xz"
[70,"name"]	"knotifyconfig"
[70,"display_name"]	"KNotifyConfig"
[70,"version"]	"5.25.0"
[70,"summary"]	"Configuration system for KNotify"
[70,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/knotifyconfig/repository"
[70,"licenses"]	["LGPLv2.1+"]
[70,"maturity"]	"stable"
[70,"platforms"]	["Linux"]
[70,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/knotifyconfig-5.25.0.tar.xz"
[71,"name"]	"kode"
[71,"summary"]	"Code generation library"
[71,"urls","vcs"]	"https://github.com/cornelius/kode/"
[71,"licenses"]	["LGPLv2.1+"]
[71,"platforms"]	["Linux"]
[72,"name"]	"kpackage"
[72,"display_name"]	"Package Framework"
[72,"version"]	"5.25.0"
[72,"summary"]	"Library to load and install packages of non binary files as they were a plugin"
[72,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kpackage/repository"
[72,"licenses"]	["LGPLv2.1+"]
[72,"maturity"]	"stable"
[72,"platforms"]	["Linux"]
[72,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kpackage-5.25.0.tar.xz"
[73,"name"]	"kparts"
[73,"display_name"]	"KParts"
[73,"version"]	"5.25.0"
[73,"summary"]	"Document centric plugin system"
[73,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kparts/repository"
[73,"licenses"]	["LGPLv2.1+"]
[73,"maturity"]	"stable"
[73,"platforms"]	["Linux"]
[73,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kparts-5.25.0.tar.xz"
[74,"name"]	"kpeople"
[74,"display_name"]	"KPeople"
[74,"version"]	"5.25.0"
[74,"summary"]	"Provides access to all contacts and the people who hold them"
[74,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kpeople/repository"
[74,"licenses"]	["LGPLv2.1+"]
[74,"maturity"]	"stable"
[74,"platforms"]	["Linux"]
[74,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kpeople-5.25.0.tar.xz"
[75,"name"]	"kplotting"
[75,"display_name"]	"KPlotting"
[75,"version"]	"5.25.0"
[75,"summary"]	"Lightweight plotting framework"
[75,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kplotting/repository"
[75,"licenses"]	["LGPLv2.1+"]
[75,"maturity"]	"stable"
[75,"platforms"]	["Linux"]
[75,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kplotting-5.25.0.tar.xz"
[76,"name"]	"kprintutils"
[76,"display_name"]	"KPrintUtils"
[76,"version"]	"5.25.0"
[76,"summary"]	"Print dialogs"
[76,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kprintutils/repository"
[76,"licenses"]	["LGPLv2.1+"]
[76,"maturity"]	"stable"
[76,"platforms"]	["Linux"]
[76,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kprintutils-5.25.0.tar.xz"
[77,"name"]	"kpty"
[77,"display_name"]	"KPty"
[77,"version"]	"5.25.0"
[77,"summary"]	"Pty abstraction"
[77,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kpty/repository"
[77,"licenses"]	["LGPLv2.1+"]
[77,"maturity"]	"stable"
[77,"platforms"]	["Linux"]
[77,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kpty-5.25.0.tar.xz"
[78,"name"]	"kqoauth"
[78,"display_name"]	"kQOAuth"
[78,"version"]	"0.98"
[78,"summary"]	"OAuth 1.0 authentication"
[78,"urls","vcs"]	"https://github.com/kypeli/kQOAuth"
[78,"licenses"]	["LGPLv2.1+"]
[78,"maturity"]	"stable"
[78,"platforms"]	["Linux"]
[78,"packages","source"]	"https://github.com/kypeli/kQOAuth/archive/0.98.tar.gz"
[79,"name"]	"kross"
[79,"display_name"]	"Kross"
[79,"version"]	"5.25.0"
[79,"summary"]	"Multi-language application scripting"
[79,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kross/repository"
[79,"licenses"]	["LGPLv2.1+"]
[79,"maturity"]	"stable"
[79,"platforms"]	["Linux"]
[79,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kross-5.25.0.tar.xz"
[80,"name"]	"krunner"
[80,"display_name"]	"KRunner"
[80,"version"]	"5.25.0"
[80,"summary"]	"Parallelized query system"
[80,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/krunner/repository"
[80,"licenses"]	["LGPLv2.1+"]
[80,"maturity"]	"stable"
[80,"platforms"]	["Linux"]
[80,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/krunner-5.25.0.tar.xz"
[81,"name"]	"kservice"
[81,"display_name"]	"KService"
[81,"version"]	"5.25.0"
[81,"summary"]	"Advanced plugin and service introspection"
[81,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kservice/repository"
[81,"licenses"]	["LGPLv2.1+"]
[81,"maturity"]	"stable"
[81,"platforms"]	["Linux"]
[81,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kservice-5.25.0.tar.xz"
[82,"name"]	"ktexteditor"
[82,"display_name"]	"KTextEditor"
[82,"version"]	"5.25.0"
[82,"summary"]	"Advanced embeddable text editor"
[82,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/ktexteditor/repository"
[82,"licenses"]	["LGPLv2.1+"]
[82,"maturity"]	"stable"
[82,"platforms"]	["Linux"]
[82,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/ktexteditor-5.25.0.tar.xz"
[83,"name"]	"ktextwidgets"
[83,"display_name"]	"KTextWidgets"
[83,"version"]	"5.25.0"
[83,"summary"]	"Advanced text editing widgets"
[83,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/ktextwidgets/repository"
[83,"licenses"]	["LGPLv2.1+"]
[83,"maturity"]	"stable"
[83,"platforms"]	["Linux"]
[83,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/ktextwidgets-5.25.0.tar.xz"
[84,"name"]	"kunitconversion"
[84,"display_name"]	"KUnitConversion"
[84,"version"]	"5.25.0"
[84,"summary"]	"Support for unit conversion"
[84,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kunitconversion/repository"
[84,"licenses"]	["LGPLv2.1+"]
[84,"maturity"]	"stable"
[84,"platforms"]	["Linux"]
[84,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kunitconversion-5.25.0.tar.xz"
[85,"name"]	"kwallet"
[85,"display_name"]	"KWallet Framework"
[85,"version"]	"5.25.0"
[85,"summary"]	"Secure and unified container for user passwords"
[85,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kwallet/repository"
[85,"licenses"]	["LGPLv2.1+"]
[85,"maturity"]	"stable"
[85,"platforms"]	["Linux"]
[85,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kwallet-5.25.0.tar.xz"
[86,"name"]	"kwayland"
[86,"display_name"]	"KWayland"
[86,"version"]	"5.4.1"
[86,"summary"]	"Qt-style API to interact with the wayland-client and wayland-server API"
[86,"urls","vcs"]	"https://projects.kde.org/projects/kde/workspace/kwayland/repository"
[86,"licenses"]	["LGPLv2.1+"]
[86,"maturity"]	"stable"
[86,"platforms"]	["Linux"]
[86,"packages","source"]	"http://download.kde.org/stable/plasma/5.4.1/kwayland-5.4.1.tar.xz"
[87,"name"]	"kwidgetsaddons"
[87,"display_name"]	"KWidgetsAddons"
[87,"version"]	"5.25.0"
[87,"summary"]	"Addons to QtWidgets"
[87,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kwidgetsaddons/repository"
[87,"licenses"]	["LGPLv2.1+"]
[87,"maturity"]	"stable"
[87,"platforms"]	["Linux"]
[87,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kwidgetsaddons-5.25.0.tar.xz"
[88,"name"]	"kwindowsystem"
[88,"display_name"]	"KWindowSystem"
[88,"version"]	"5.25.0"
[88,"summary"]	"Access to the windowing system"
[88,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kwindowsystem/repository"
[88,"licenses"]	["LGPLv2.1+"]
[88,"maturity"]	"stable"
[88,"platforms"]	["Linux"]
[88,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kwindowsystem-5.25.0.tar.xz"
[89,"name"]	"kxmlgui"
[89,"display_name"]	"KXMLGUI"
[89,"version"]	"5.25.0"
[89,"summary"]	"User configurable main windows"
[89,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kxmlgui/repository"
[89,"licenses"]	["LGPLv2.1+"]
[89,"maturity"]	"stable"
[89,"platforms"]	["Linux"]
[89,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kxmlgui-5.25.0.tar.xz"
[90,"name"]	"kxmlrpcclient"
[90,"display_name"]	"KXmlRpcClient"
[90,"version"]	"5.25.0"
[90,"summary"]	"Interaction with XMLRPC services"
[90,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/kxmlrpcclient/repository"
[90,"licenses"]	["LGPLv2.1+"]
[90,"maturity"]	"stable"
[90,"platforms"]	["Linux"]
[90,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/kxmlrpcclient-5.25.0.tar.xz"
[91,"name"]	"libcommuni"
[91,"version"]	"3.4.0"
[91,"summary"]	"IRC framework"
[91,"urls","vcs"]	"https://github.com/communi/libcommuni"
[91,"licenses"]	["BSD"]
[91,"maturity"]	"stable"
[91,"platforms"]	["Linux","Windows","OS X"]
[91,"packages","source"]	"https://github.com/communi/libcommuni/archive/v3.4.0.tar.gz"
[92,"name"]	"libengsas"
[92,"version"]	"0.5.2"
[92,"summary"]	"Widgets for technical applications"
[92,"urls","vcs"]	"https://svn.engsas.de/libengsas"
[92,"licenses"]	["LGPLv2.1+"]
[92,"maturity"]	"stable"
[92,"platforms"]	["Linux","Windows","Mac OS X"]
[92,"packages","source"]	"http://sourceforge.net/projects/libengsas/files/libengsas0_0.5.2.orig.tar.bz2/download"
[93,"name"]	"libkexiv2"
[93,"version"]	"4.11.1"
[93,"summary"]	"Qt bindings for Exiv2, the library to manipulate picture meta data"
[93,"urls","vcs"]	"https://projects.kde.org/projects/kde/kdegraphics/libs/libkexiv2/repository"
[93,"licenses"]	["GPLv2+"]
[93,"maturity"]	"stable"
[93,"platforms"]	["Linux"]
[93,"packages","source"]	"http://download.kde.org/stable/4.11.1/src/libkexiv2-4.11.1.tar.xz"
[94,"name"]	"liblastfm"
[94,"version"]	"1.0.8"
[94,"summary"]	"A Qt C++ library for the Last.fm webservices"
[94,"urls","vcs"]	"https://github.com/lastfm/liblastfm"
[94,"licenses"]	["GPLv3"]
[94,"maturity"]	"stable"
[94,"platforms"]	["Linux","Windows","OS X"]
[94,"packages","source"]	"https://github.com/lastfm/liblastfm/archive/1.0.8.tar.gz"
[95,"name"]	"libmm-qt"
[95,"version"]	"1.0.1"
[95,"summary"]	"Qt wrapper for ModemManager DBus API"
[95,"urls","vcs"]	"https://projects.kde.org/projects/extragear/libs/libmm-qt/repository"
[95,"licenses"]	["LGPL"]
[95,"maturity"]	"stable"
[95,"platforms"]	["Linux"]
[95,"packages","source"]	"http://download.kde.org/unstable/modemmanager-qt/1.0.1/src/libmm-qt-1.0.1-1.tar.xz"
[96,"name"]	"libnm-qt"
[96,"version"]	"0.9.8.2"
[96,"summary"]	"Qt wrapper for NetworkManager DBus API"
[96,"urls","vcs"]	"https://projects.kde.org/projects/extragear/libs/libnm-qt/repository"
[96,"licenses"]	["LGPL"]
[96,"maturity"]	"stable"
[96,"platforms"]	["Linux"]
[96,"packages","source"]	"http://download.kde.org/unstable/networkmanager-qt/0.9.8.2/src/libnm-qt-0.9.8.2.tar.xz"
[97,"name"]	"libqinfinity"
[97,"version"]	"0.5.1"
[97,"summary"]	"Qt wrapper around libinfinity, a library for collaborative editing"
[97,"urls","vcs"]	"https://projects.kde.org/projects/playground/libs/libqinfinity/repository"
[97,"licenses"]	["GPLv2+"]
[97,"maturity"]	"alpha"
[97,"platforms"]	["Linux"]
[97,"packages","source"]	"http://download.kde.org/stable/libqinfinity/0.5.1/src/libqinfinity-v0.5.1.tar.xz"
[98,"name"]	"libqtlua"
[98,"version"]	"2.0"
[98,"summary"]	"Framework for embedding Lua in Qt applications"
[98,"urls","vcs"]	"http://svn.savannah.nongnu.org/viewvc/?root=libqtlua"
[98,"licenses"]	["LGPLv3+"]
[98,"maturity"]	"stable"
[98,"platforms"]	["Linux"]
[98,"packages","source"]	"http://download.savannah.gnu.org/releases/libqtlua/libqtlua-2.0.tar.gz"
[99,"name"]	"libqxt"
[99,"version"]	"0.6.2"
[99,"summary"]	"Utility classes for Qt"
[99,"urls","vcs"]	"http://dev.libqxt.org/libqxt/src"
[99,"licenses"]	["BSD-3-Clause"]
[99,"maturity"]	"stable"
[99,"platforms"]	["Linux","Windows","OS X"]
[99,"packages","source"]	"http://dev.libqxt.org/libqxt/get/v0.6.2.tar.gz"
[100,"name"]	"libsystemd-qt"
[100,"version"]	"208"
[100,"summary"]	"Qt-only wrapper for the Systemd API"
[100,"urls","vcs"]	"https://github.com/andreascarpino/libsystemd-qt"
[100,"licenses"]	["LGPLv3"]
[100,"maturity"]	"alpha"
[100,"platforms"]	["Linux"]
[100,"packages","source"]	"https://github.com/andreascarpino/libsystemd-qt/archive/208.tar.gz"
[101,"name"]	"libtmdbqt"
[101,"display_name"]	"TmdbQt"
[101,"summary"]	"Library for querying The Movie Database API (themoviedb.org)"
[101,"urls","vcs"]	"git clone git://anongit.kde.org/libtmdbqt"
[101,"licenses"]	["LGPLv2.1+"]
[101,"platforms"]	["Linux","Windows","MacOS"]
[102,"name"]	"limereport"
[102,"display_name"]	"LimeReport"
[102,"version"]	"1.3.11"
[102,"summary"]	"Report printing engine"
[102,"urls","vcs"]	"https://github.com/fralx/LimeReport"
[102,"licenses"]	["GPLv3+","LGPLv2.1+"]
[102,"maturity"]	"stable"
[102,"platforms"]	["Linux","Windows","OS X"]
[102,"packages","source"]	"https://sourceforge.net/projects/limereport/files/Sources/limereport_1_3_11.7z/download"
[103,"name"]	"log4qt"
[103,"version"]	"0.3"
[103,"summary"]	"C++ port of the Log4j logging framework"
[103,"urls","vcs"]	"http://sourceforge.net/p/log4qt/code/HEAD/tree/"
[103,"licenses"]	["Apache-v2.0"]
[103,"maturity"]	"beta"
[103,"platforms"]	["Linux","Windows"]
[103,"packages","source"]	"http://sourceforge.net/projects/log4qt/files/Log4Qt/0.3/log4qt-0.3.tar.gz/download"
[104,"name"]	"log4qt-fork"
[104,"display_name"]	"Log4Qt"
[104,"version"]	"1.2.0"
[104,"summary"]	"C++ port of the Log4j logging framework"
[104,"urls","vcs"]	"https://github.com/MEONMedical/Log4Qt.git"
[104,"licenses"]	["Apache-2.0"]
[104,"maturity"]	"stable"
[104,"platforms"]	["Linux","Windos","OS X"]
[104,"packages","source"]	"https://github.com/MEONMedical/Log4Qt/archive/v1.2.0.tar.gz"
[105,"name"]	"lxqt_wallet"
[105,"version"]	"2.2.0"
[105,"summary"]	"Secure storage of data in an internal storage system or in KDE KWallet or GNOME libsecret"
[105,"urls","vcs"]	"https://github.com/mhogomchungu/lxqt_wallet.git"
[105,"licenses"]	["BSD"]
[105,"maturity"]	"stable"
[105,"platforms"]	["Linux"]
[105,"packages","source"]	"https://github.com/mhogomchungu/lxqt_wallet/releases/download/2.2.0/lxqt_wallet-2.2.0.tar.xz"
[106,"name"]	"marble"
[106,"version"]	"1.6.1"
[106,"summary"]	"Marble Virtual Globe"
[106,"urls","vcs"]	"https://projects.kde.org/projects/kde/kdeedu/marble"
[106,"licenses"]	["LGPLv2.1"]
[106,"maturity"]	"stable"
[106,"platforms"]	["Linux","Windows","MacOS","Maemo","MeeGo"]
[106,"packages","source"]	"http://download.kde.org/stable/4.11.1/src/marble-4.11.1.tar.xz"
[107,"name"]	"mimetypes-qt4"
[107,"summary"]	"Backport of the Qt 5 mimetypes api to Qt 4"
[107,"urls","vcs"]	"http://code.qt.io/cgit/playground/mimetypes.git/"
[107,"licenses"]	["LGPLv2.1","GPLv3"]
[107,"platforms"]	["Linux","Windows","OS X"]
[108,"name"]	"modemmanager-qt"
[108,"display_name"]	"ModemManagerQt"
[108,"version"]	"5.25.0"
[108,"summary"]	"Qt wrapper for ModemManager API"
[108,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/modemmanager-qt/repository"
[108,"licenses"]	["LGPLv2.1+"]
[108,"maturity"]	"stable"
[108,"platforms"]	["Linux"]
[108,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/modemmanager-qt-5.25.0.tar.xz"
[109,"name"]	"ncreport"
[109,"summary"]	"Report generator"
[109,"licenses"]	["Commercial"]
[109,"maturity"]	"stable"
[109,"platforms"]	["Linux","Windows","OS X"]
[110,"name"]	"neiasound"
[110,"display_name"]	"neiasound"
[110,"version"]	"5.25.0"
[110,"summary"]	"OpenAl wrapper for Qt apps and games"
[110,"urls","vcs"]	"https://github.com/lucaspcamargo/neiasound"
[110,"licenses"]	["BSD 2-clause"]
[110,"maturity"]	"stable"
[110,"platforms"]	["Cross-platform"]
[110,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/neiasound-5.25.0.tar.xz"
[111,"name"]	"networkmanager-qt"
[111,"display_name"]	"NetworkManagerQt"
[111,"version"]	"5.25.0"
[111,"summary"]	"Qt wrapper for NetworkManager API"
[111,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/networkmanager-qt/repository"
[111,"licenses"]	["LGPLv2.1+"]
[111,"maturity"]	"stable"
[111,"platforms"]	["Linux"]
[111,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/networkmanager-qt-5.25.0.tar.xz"
[112,"name"]	"noron"
[112,"display_name"]	"Noron"
[112,"version"]	"0.1"
[112,"summary"]	"Remote object sharing"
[112,"licenses"]	["GPLv3","LGPLv3"]
[112,"maturity"]	"stable"
[112,"platforms"]	["Linux","Windows","Mac OS X","Android","IOS"]
[112,"packages","source"]	"https://github.com/HamedMasafi/Noron/archive/master.zip"
[113,"name"]	"novile"
[113,"version"]	"0.5"
[113,"summary"]	"Source code editor component for Qt"
[113,"urls","vcs"]	"https://github.com/tucnak/novile"
[113,"licenses"]	["GPL"]
[113,"maturity"]	"alpha"
[113,"platforms"]	["Linux"]
[113,"packages","source"]	"https://github.com/tucnak/novile/archive/v0.5.tar.gz"
[114,"name"]	"nut"
[114,"display_name"]	"Nut"
[114,"version"]	"0.1"
[114,"summary"]	"Object relational mapper for Qt5"
[114,"licenses"]	["GPLv3","LGPLv3"]
[114,"maturity"]	"stable"
[114,"platforms"]	["Linux","Windows","Mac OS X","Android","IOS"]
[114,"packages","source"]	"https://github.com/HamedMasafi/Nut/archive/master.zip"
[115,"name"]	"o2"
[115,"version"]	"1.0"
[115,"summary"]	"A library encapsulating OAuth 1.0 and 2.0 client authentication flows"
[115,"urls","vcs"]	"https://github.com/pipacs/o2"
[115,"licenses"]	["Simplified BSD License"]
[115,"maturity"]	"stable"
[115,"platforms"]	["All platforms supported by Qt"]
[115,"packages","source"]	"https://github.com/pipacs/o2/archive/master.zip"
[116,"name"]	"osgqtquick"
[116,"display_name"]	"osgQtQuick"
[116,"version"]	"2.0.0-alpha-2"
[116,"summary"]	"OpenSceneGraph QML Modules"
[116,"licenses"]	["LGPLv2.1+"]
[116,"maturity"]	"alpha"
[116,"platforms"]	["Linux","Windows"]
[116,"packages","source"]	"https://github.com/podsvirov/osgqtquick/archive/v2.0.0-alpha-2.tar.gz"
[117,"name"]	"oxygen-icons5"
[117,"display_name"]	"Oxygen Icons"
[117,"version"]	"5.25.0"
[117,"summary"]	"Oxygen icon theme"
[117,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/oxygen-icons5/repository"
[117,"licenses"]	["LGPLv2.1+"]
[117,"maturity"]	"stable"
[117,"platforms"]	["Linux"]
[117,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/oxygen-icons5-5.25.0.tar.xz"
[118,"name"]	"packagekit-qt"
[118,"version"]	"0.8.8"
[118,"summary"]	"Qt bindings for PackageKit, the backend for managing software installation"
[118,"urls","vcs"]	"http://gitorious.org/packagekit/packagekit/trees/master/lib/packagekit-qt"
[118,"licenses"]	["GPLv2+"]
[118,"maturity"]	"stable"
[118,"platforms"]	["Linux"]
[118,"packages","source"]	"http://www.packagekit.org/releases/PackageKit-Qt-0.8.8.tar.xz"
[119,"name"]	"phonon"
[119,"version"]	"4.6.0"
[119,"summary"]	"Phonon Multimedia Platform Abstraction"
[119,"urls","vcs"]	"https://projects.kde.org/projects/kdesupport/phonon"
[119,"licenses"]	["LGPLv2.0+"]
[119,"maturity"]	"stable"
[119,"platforms"]	["Linux"]
[119,"packages","source"]	"http://download.kde.org/stable/phonon/4.6.0/src/phonon-4.6.0.tar.xz"
[120,"name"]	"plasma-framework"
[120,"display_name"]	"Plasma Framework"
[120,"version"]	"5.25.0"
[120,"summary"]	"Plugin based UI runtime used to write primary user interfaces"
[120,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/plasma-framework/repository"
[120,"licenses"]	["LGPLv2.1+"]
[120,"maturity"]	"stable"
[120,"platforms"]	["Linux"]
[120,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/plasma-framework-5.25.0.tar.xz"
[121,"name"]	"polkit-qt-1"
[121,"version"]	"0.103.0"
[121,"summary"]	"Qt bindings for PolicyKit"
[121,"urls","vcs"]	"https://projects.kde.org/projects/kdesupport/polkit-qt-1/repository"
[121,"licenses"]	["LGPLv2.1+"]
[121,"maturity"]	"stable"
[121,"platforms"]	["Linux"]
[121,"packages","source"]	"http://download.kde.org/stable/apps/KDE4.x/admin/polkit-qt-1-0.103.0.tar.bz2"
[122,"name"]	"poppler-qt"
[122,"version"]	"0.24.1"
[122,"summary"]	"Qt bindings for Poppler, the PDF rendering library"
[122,"urls","vcs"]	"http://cgit.freedesktop.org/poppler/poppler/tree/qt4"
[122,"licenses"]	["GPLv2+"]
[122,"maturity"]	"stable"
[122,"platforms"]	["Linux"]
[122,"packages","source"]	"http://poppler.freedesktop.org/poppler-0.24.1.tar.xz"
[123,"name"]	"pythonqt"
[123,"version"]	"2.1"
[123,"summary"]	"Framework for embedding Python in Qt applications"
[123,"urls","vcs"]	"http://sourceforge.net/p/pythonqt/code/HEAD/tree/"
[123,"licenses"]	["LGPLv2.1+"]
[123,"maturity"]	"stable"
[123,"platforms"]	["Linux"]
[123,"packages","source"]	"http://sourceforge.net/projects/pythonqt/files/pythonqt/PythonQt-2.1/PythonQt2.1_Qt4.8.zip/download"
[124,"name"]	"q7goodies"
[124,"summary"]	"Windows 7 taskbar extensions"
[124,"licenses"]	["Commercial"]
[124,"maturity"]	"stable"
[124,"platforms"]	["Windows"]
[125,"name"]	"qanmenubar"
[125,"display_name"]	"QanMenuBar"
[125,"version"]	"0.0.4"
[125,"summary"]	"QanMenuBar is lightweight dynamic QML menu component similar to PieMenu"
[125,"urls","vcs"]	"https://github.com/cneben/QuickQanava/tree/master/QanMenuBar"
[125,"licenses"]	["GPLv3+"]
[125,"maturity"]	"alpha"
[125,"platforms"]	["Linux","Windows","Android"]
[125,"packages","source"]	"https://github.com/cneben/QuickQanava/archive/0.4.tar.gz"
[126,"name"]	"qaudiocoder"
[126,"version"]	"0.1.0"
[126,"summary"]	"Library for audio decoding, encoding and audio file conversion"
[126,"urls","vcs"]	"https://github.com/visore/QAudioCoder"
[126,"licenses"]	["LGPLv3+"]
[126,"maturity"]	"alpha"
[126,"platforms"]	["Linux"]
[126,"packages","source"]	"http://sourceforge.net/projects/qaudiocoder/files/Version%200.1.0/Source%20Code/qaudiocoder-0.1.0-source.gz/download"
[127,"name"]	"qca"
[127,"version"]	"2.0.3"
[127,"summary"]	"Qt Cryptographic Architecture"
[127,"urls","vcs"]	"http://websvn.kde.org/trunk/kdesupport/qca/"
[127,"licenses"]	["LGPLv2.1+"]
[127,"maturity"]	"stable"
[127,"platforms"]	["Linux"]
[127,"packages","source"]	"http://delta.affinix.com/download/qca/2.0/qca-2.0.3.tar.bz2"
[128,"name"]	"qcustomplot"
[128,"display_name"]	"QCustomPlot"
[128,"version"]	"1.3.2"
[128,"summary"]	"Plotting widget for Qt"
[128,"urls","vcs"]	"https://gitlab.com/DerManu/QCustomPlot"
[128,"licenses"]	["GPLv3+"]
[128,"maturity"]	"stable"
[128,"platforms"]	["Linux"]
[128,"packages","source"]	"http://www.qcustomplot.com/release/1.3.2/QCustomPlot.tar.gz"
[129,"name"]	"qdatacube"
[129,"summary"]	"Datacube for Qt"
[129,"urls","vcs"]	"https://gitlab.com/AngeOptimization/qdatacube"
[129,"licenses"]	["LGPL"]
[129,"maturity"]	"stable"
[129,"platforms"]	["Linux","Windows"]
[130,"name"]	"qdbf"
[130,"summary"]	"Library for handling dbf files"
[130,"urls","vcs"]	"https://code.google.com/p/qdbf/source/browse/"
[130,"licenses"]	["LGPLv2.1+"]
[130,"platforms"]	["Linux"]
[131,"name"]	"qdecimal"
[131,"display_name"]	"QDecimail"
[131,"version"]	"1.01"
[131,"summary"]	"Decimal arithmetic library for Qt framework"
[131,"urls","vcs"]	"https://code.google.com/p/qdecimal/source/browse/"
[131,"licenses"]	["LGPL v2.1"]
[131,"maturity"]	"stable"
[131,"platforms"]	["Linux","Windows","OS X"]
[131,"packages","source"]	"https://code.google.com/p/qdecimal/downloads/detail?name=qdecimal-1.0.1.tgz&can=2&q="
[132,"name"]	"qdjango"
[132,"version"]	"0.4.0"
[132,"summary"]	"ORM and HTTP request/response framework"
[132,"licenses"]	["GPLv2.1+"]
[132,"maturity"]	"stable"
[132,"platforms"]	["Linux","Windows","OS X"]
[132,"packages","source"]	"https://qdjango.googlecode.com/files/qdjango-0.4.0.tar.gz"
[133,"name"]	"qextserialport"
[133,"version"]	"1.2RC"
[133,"summary"]	"Cross platform interface to serial ports."
[133,"licenses"]	["MIT"]
[133,"maturity"]	"beta"
[133,"platforms"]	["Linux","Windows","OS X"]
[133,"packages","source"]	"https://qextserialport.googlecode.com/files/qextserialport-1.2rc.zip"
[134,"name"]	"qfb"
[134,"summary"]	"Client library for accessing Facebook graph API"
[134,"urls","vcs"]	"https://github.com/SfietKonstantin/qfb"
[134,"licenses"]	["GPLv3+"]
[134,"platforms"]	["Linux"]
[135,"name"]	"qicstable"
[135,"display_name"]	"QicsTable"
[135,"summary"]	"High performance Qt table widget"
[135,"licenses"]	["GPLV3+","LGPLv2.1+","Commercial","Evaluation"]
[135,"platforms"]	["Linux","Windows","OS X"]
[136,"name"]	"qimageblitz"
[136,"version"]	"0.0.4"
[136,"summary"]	"Image Effect Library for KDE"
[136,"urls","vcs"]	"http://websvn.kde.org/trunk/kdesupport/qimageblitz/"
[136,"licenses"]	["BSD 3-Clause"]
[136,"maturity"]	"stable"
[136,"platforms"]	["Linux"]
[136,"packages","source"]	"http://sourceforge.net/projects/qimageblitz/files/qimageblitz/QImageBlitz%200.0.4/qimageblitz-0.0.4.tar.bz2/download"
[136,"packages","openSUSE","11.4","package_name"]	"libqimageblitz4"
[136,"packages","openSUSE","11.4","repository","name"]	"openSUSE-11.4-Oss"
[137,"name"]	"qjson"
[137,"version"]	"0.8.1"
[137,"summary"]	"JSON parser for Qt"
[137,"urls","vcs"]	"https://github.com/flavio/qjson"
[137,"licenses"]	["LGPL"]
[137,"maturity"]	"stable"
[137,"platforms"]	["Linux"]
[137,"packages","source"]	"https://github.com/flavio/qjson/archive/0.8.1.tar.gz"
[138,"name"]	"qjsonrpc"
[138,"summary"]	"Implementation of the JSON-RPC protocol"
[138,"urls","vcs"]	"https://bitbucket.org/devonit/qjsonrpc/src"
[138,"licenses"]	["LGPLv2.1+"]
[138,"platforms"]	["Linux"]
[139,"name"]	"qlogsystem"
[139,"version"]	"1.0.7"
[139,"summary"]	"qlogsystem is a very efficient and easy to use logger library"
[139,"urls","vcs"]	"https://github.com/balabit/qlogsystem"
[139,"licenses"]	["LGPLv2.1"]
[139,"maturity"]	"stable"
[139,"platforms"]	["Linux","Windows"]
[139,"packages","source"]	"https://github.com/balabit/qlogsystem/archive/v1.0.7.tar.gz"
[140,"name"]	"qoauth"
[140,"version"]	"1.0.1"
[140,"summary"]	"Library for OAuth authorization scheme"
[140,"urls","vcs"]	"http://github.com/ayoy/qoauth"
[140,"licenses"]	["LGPL"]
[140,"maturity"]	"stable"
[140,"platforms"]	["Linux"]
[140,"packages","source"]	"https://github.com/ayoy/qoauth/archive/v1.0.1.tar.gz"
[140,"packages","openSUSE","11.4","package_name"]	"libqoauth1"
[140,"packages","openSUSE","11.4","repository","name"]	"openSUSE-11.4-Oss"
[141,"name"]	"qscintilla"
[141,"version"]	"2.9.2"
[141,"summary"]	"Qt port of Scintilla C++ editor control"
[141,"licenses"]	["GPLv2","GPLv3","Commercial"]
[141,"maturity"]	"stable"
[141,"platforms"]	["Linux","Windows","OS X","iOS","Android"]
[141,"packages","source"]	"https://sourceforge.net/projects/pyqt/files/QScintilla2/QScintilla-2.9.2/QScintilla_gpl-2.9.2.tar.gz/download"
[142,"name"]	"qserialdevice"
[142,"summary"]	"Cross-platform library for accessing serial devices"
[142,"urls","vcs"]	"https://gitorious.org/qserialdevice/qserialdevice"
[142,"licenses"]	["GPLv2+"]
[142,"platforms"]	["Linux","Windows"]
[143,"name"]	"qserialport"
[143,"version"]	"0.1.1"
[143,"summary"]	"Cross-platform serial port driver"
[143,"urls","vcs"]	"http://sourceforge.net/p/qserialport/code/HEAD/tree/"
[143,"licenses"]	["GPLv2"]
[143,"maturity"]	"prealpha"
[143,"platforms"]	["Linux","Windows"]
[143,"packages","source"]	"http://sourceforge.net/projects/qserialport/files/qserialport-0.1.1.zip/download"
[144,"name"]	"qsint"
[144,"display_name"]	"QSint"
[144,"summary"]	"Open source Qt Widgets Collection"
[144,"urls","vcs"]	"http://sourceforge.net/p/qsint/code"
[144,"licenses"]	["LGPL"]
[144,"maturity"]	"stable"
[144,"platforms"]	["Linux","Windows","OS X"]
[145,"name"]	"qslog"
[145,"version"]	"2.0b1"
[145,"summary"]	"Simple Qt logger"
[145,"urls","vcs"]	"https://bitbucket.org/razvanpetru/qt-components/src"
[145,"licenses"]	["BSD-3-Clause"]
[145,"maturity"]	"beta"
[145,"platforms"]	["Linux"]
[145,"packages","source"]	"https://bitbucket.org/razvanpetru/qt-components/downloads/QsLog_2.0b1.zip"
[146,"name"]	"qsqlmigrator"
[146,"version"]	"1.0"
[146,"summary"]	"QSqlMigrator - keep track of your database migrations"
[146,"urls","vcs"]	"https://github.com/hicknhack-software/QSqlMigrator"
[146,"licenses"]	["LGPLv2.1","GPLv3"]
[146,"maturity"]	"stable"
[146,"platforms"]	["Linux","Mac","Windows"]
[146,"packages","source"]	"https://github.com/hicknhack-software/QSqlMigrator/archive/v1.0.tar.gz"
[147,"name"]	"qt-certificate-addon"
[147,"version"]	"edge"
[147,"summary"]	"Qt Certificate Addon"
[147,"urls","vcs"]	"https://gitorious.org/qt-certificate-addon"
[147,"licenses"]	["LGPLv2.1"]
[147,"maturity"]	"edge"
[147,"platforms"]	["Linux"]
[147,"packages","source"]	"https://gitorious.org/qt-certificate-addon/qt-certificate-addon/archive/f807e92da99d0a770d2bf22adff8b728dab83d29.tar.gz"
[148,"name"]	"qt-gstreamer"
[148,"version"]	"0.10.2"
[148,"summary"]	"Qt bindings for GStreamer"
[148,"urls","vcs"]	"http://cgit.freedesktop.org/gstreamer/qt-gstreamer"
[148,"licenses"]	["LGPLv2.1+"]
[148,"maturity"]	"stable"
[148,"platforms"]	["Linux"]
[148,"packages","source"]	"http://gstreamer.freedesktop.org/src/qt-gstreamer/qt-gstreamer-0.10.2.tar.gz"
[149,"name"]	"qtargparser"
[149,"version"]	"2.0.0"
[149,"summary"]	"Command line parsing"
[149,"urls","vcs"]	"https://github.com/igormironchik/qtargparser"
[149,"licenses"]	["MIT"]
[149,"maturity"]	"stable"
[149,"platforms"]	["Linux"]
[149,"packages","source"]	"https://github.com/igormironchik/qtargparser/archive/2.0.0.tar.gz"
[150,"name"]	"qtav"
[150,"version"]	"1.10.0"
[150,"summary"]	"A cross-platform multimedia playback framework based on Qt and FFmpeg."
[150,"urls","vcs"]	"https://github.com/wang-bin/QtAV"
[150,"licenses"]	["LGPLv2.1+","GPLv3"]
[150,"maturity"]	"stable"
[150,"platforms"]	["Windows","Linux","OS X","Android","iOS"]
[150,"packages","source"]	"https://github.com/wang-bin/QtAV/archive/v1.10.0.tar.gz"
[151,"name"]	"qtdropbox"
[151,"version"]	"5.0"
[151,"summary"]	"Qt Dropbox"
[151,"urls","vcs"]	"https://github.com/lycis/QtDropbox/"
[151,"licenses"]	["LGPLv3+"]
[151,"maturity"]	"stable"
[151,"platforms"]	["Linux","Windows"]
[151,"packages","source"]	"https://github.com/lycis/QtDropbox/archive/master.zip"
[152,"name"]	"qtermwidget"
[152,"version"]	"0.1"
[152,"summary"]	"Embeddable console widget"
[152,"urls","vcs"]	"http://qtermwidget.cvs.sourceforge.net/viewvc/qtermwidget/qtermwidget/"
[152,"licenses"]	["LGPLv2+"]
[152,"maturity"]	"alpha"
[152,"platforms"]	["Linux"]
[152,"packages","source"]	"http://sourceforge.net/project/platformdownload.php?group_id=227230"
[153,"name"]	"qtffmpegwrapper"
[153,"version"]	"20130507"
[153,"summary"]	"Qt FFmpeg Wrapper for video frame encoding and decoding"
[153,"urls","vcs"]	"https://code.google.com/p/qtffmpegwrapper/source/browse/"
[153,"licenses"]	["BSD-3-Clause"]
[153,"maturity"]	"stable"
[153,"platforms"]	["Linux","Windows"]
[153,"packages","source"]	"https://qtffmpegwrapper.googlecode.com/files/qtffmpegwrapper_src-20130507.zip"
[154,"name"]	"qtftp"
[154,"summary"]	"FTP implementation"
[154,"urls","vcs"]	"http://code.qt.io/cgit/qt/qtftp.git/"
[154,"licenses"]	["LGPLv2.1","GPLv3","Commercial"]
[154,"platforms"]	["Linux","Windows","OS X"]
[155,"name"]	"qtgamepad"
[155,"summary"]	"Reading input from gamepad devices"
[155,"urls","vcs"]	"https://github.com/nezticle/qtgamepad"
[155,"licenses"]	["MIT"]
[155,"platforms"]	["Linux"]
[156,"name"]	"qtgooglespeech"
[156,"summary"]	"Library to use Google Speech service"
[156,"urls","vcs"]	"https://github.com/niqt/QtGoogleSpeech"
[156,"licenses"]	["LGPL"]
[156,"platforms"]	["Linux"]
[157,"name"]	"qthttp"
[157,"summary"]	"HTTP implementation"
[157,"urls","vcs"]	"http://code.qt.io/cgit/qt/qthttp.git/"
[157,"licenses"]	["LGPLv2.1","GPLv3","Commercial"]
[157,"platforms"]	["Linux","Windows","OS X"]
[158,"name"]	"qtilities"
[158,"version"]	"1.4"
[158,"summary"]	"Building blocks for Qt applications"
[158,"urls","vcs"]	"https://github.com/JPNaude/Qtilities"
[158,"licenses"]	["GPLv3","LGPLv2.1","Commercial"]
[158,"maturity"]	"stable"
[158,"platforms"]	["Linux"]
[158,"packages","source"]	"http://github.com/JPNaude/Qtilities/zipball/v1.4"
[159,"name"]	"qtinstallerframework"
[159,"version"]	"1.4.0"
[159,"summary"]	"Tools and utilities to create installers for the supported desktop Qt platforms."
[159,"licenses"]	["LGPLv2.1+"]
[159,"maturity"]	"stable"
[159,"platforms"]	["Linux","Windows","OS X"]
[159,"packages","source"]	"http://download.qt-project.org/official_releases/qt-installer-framework/1.4.0/qt-installer-framework-opensource-1.4.0-src.zip"
[160,"name"]	"qtioccontainer"
[160,"version"]	"3.5"
[160,"summary"]	"Application framework inspired by Inversion Of Control concept"
[160,"urls","vcs"]	"http://svn.sourceforge.net/qtioccontainer"
[160,"licenses"]	["LGPLv2"]
[160,"maturity"]	"beta"
[160,"platforms"]	["Linux"]
[160,"packages","source"]	"http://sourceforge.net/projects/qtioccontainer/files/qtioccontainer/qtioccontainer-3.5/qtioccontainer-3-5.tar.gz/download"
[161,"name"]	"qtitanchart"
[161,"version"]	"2.1"
[161,"summary"]	"Generation of interactive diagrams"
[161,"licenses"]	["Commercial"]
[161,"maturity"]	"stable"
[161,"platforms"]	["Linux","Windows","OS X"]
[162,"name"]	"qtitanribbon"
[162,"version"]	"3.1"
[162,"summary"]	"Components for ribbon-style user interfaces"
[162,"licenses"]	["Commercial"]
[162,"maturity"]	"stable"
[162,"platforms"]	["Linux","Windows","OS X"]
[163,"name"]	"qtkeychain"
[163,"version"]	"0.4.0"
[163,"summary"]	"Platform-independent Qt API for storing passwords securely"
[163,"urls","vcs"]	"https://github.com/frankosterfeld/qtkeychain"
[163,"licenses"]	["BSD-2"]
[163,"maturity"]	"stable"
[163,"platforms"]	["Linux","Windows","MacOS"]
[163,"packages","source"]	"https://github.com/frankosterfeld/qtkeychain/archive/v0.4.0.tar.gz"
[164,"name"]	"qtmodeling"
[164,"summary"]	"Framework for supporting model-driven engineering"
[164,"urls","vcs"]	"http://code.qt.io/cgit/qt/qtmodeling.git/"
[164,"licenses"]	["LGPLv2.1","GPLv3"]
[164,"platforms"]	["Linux","Windows","OSX"]
[165,"name"]	"qtoolbox"
[165,"summary"]	"Set of tools for Qt development"
[165,"urls","vcs"]	"https://github.com/detro/qtoolbox"
[165,"licenses"]	["Apache-2.0"]
[165,"platforms"]	["Linux","Windows","OS X"]
[166,"name"]	"qtoptimization"
[166,"summary"]	"Module for optimization algorithms"
[166,"urls","vcs"]	"https://gitorious.org/qtoptimization/qtoptimization"
[166,"licenses"]	["LGPLv2.1","GPLv3"]
[166,"platforms"]	["Linux","Windows","OSX"]
[167,"name"]	"qtorm"
[167,"summary"]	"Object relational model inspired from Django"
[167,"urls","vcs"]	"https://github.com/steckdenis/qtorm.git"
[167,"licenses"]	["LGPLv2.1"]
[167,"platforms"]	["Linux","Windows","OSX"]
[168,"name"]	"qtrest"
[168,"display_name"]	"Qt REST Client"
[168,"summary"]	"Qt REST Client Framework for work JSON/XML APIs"
[168,"urls","vcs"]	"https://github.com/kafeg/qtrest.git"
[168,"licenses"]	["MIT"]
[168,"maturity"]	"beta"
[168,"platforms"]	["Android","iOS","Windows","Linux","OS X"]
[169,"name"]	"qtrpt"
[169,"display_name"]	"QtRPT"
[169,"summary"]	"Report engine"
[169,"licenses"]	["Apache 2.0"]
[169,"maturity"]	"stable"
[169,"platforms"]	["Linux","Windows","OS X"]
[170,"name"]	"qtsharp"
[170,"display_name"]	"QtSharp"
[170,"version"]	"0.5.1"
[170,"summary"]	"Mono/.NET bindings for Qt"
[170,"urls","vcs"]	"https://github.com/ddobrev/QtSharp"
[170,"licenses"]	["Apache-v2.0"]
[170,"maturity"]	"alpha"
[170,"platforms"]	["Windows"]
[170,"packages","source"]	"https://github.com/ddobrev/QtSharp/releases/download/0.5.1/QtSharp-0.5.1-Qt-5.6.1-MinGW.zip"
[171,"name"]	"qtspeech"
[171,"summary"]	"Cross-platform API to access and use system text-to-spech engines"
[171,"urls","vcs"]	"http://code.qt.io/cgit/qt/qtspeech.git/"
[171,"licenses"]	["LGPLv3+"]
[171,"platforms"]	["Windows","Linux","OSX"]
[172,"name"]	"qtuio"
[172,"summary"]	"Interface to TUIO, the protocol for tangible multi-touch surfaces"
[172,"urls","vcs"]	"https://github.com/x29a/qTUIO"
[172,"licenses"]	["GPLv3+"]
[172,"platforms"]	["Linux"]
[173,"name"]	"qtuiotouch"
[173,"summary"]	"Qt plugin for TUIO input devices"
[173,"urls","vcs"]	"https://github.com/dancasimiro/qtuiotouch"
[173,"licenses"]	["MIT"]
[173,"platforms"]	["Linux"]
[174,"name"]	"qtunits"
[174,"display_name"]	"QtUnits"
[174,"summary"]	"Qt runtime unit conversion library built using (and compatible with) Boost::Units."
[174,"urls","vcs"]	"https://github.com/hrobeers/QtUnits"
[174,"licenses"]	["BSD 2-clause"]
[174,"platforms"]	["Linux","Windows","MacOS"]
[175,"name"]	"qtvkontakte"
[175,"display_name"]	"QtVkontakte"
[175,"summary"]	"Qt wrapper around Vkontakte Android SDK (https://vk.com, Russian social network)"
[175,"urls","vcs"]	"https://github.com/gilmanov-ildar/QtVkontakte.git"
[175,"licenses"]	["GPL2"]
[175,"platforms"]	["Android"]
[176,"name"]	"qtwebapp"
[176,"version"]	"1.3.1"
[176,"summary"]	"Web application framework similar to Java Servlet API"
[176,"urls","vcs"]	""
[176,"licenses"]	["LGPLv3"]
[176,"maturity"]	"stable"
[176,"platforms"]	["Linux","Windows","OS X"]
[176,"packages","source"]	"http://stefanfrings.de/qtwebapp/QtWebApp-src.zip"
[177,"name"]	"qtwebkit"
[177,"version"]	"5.1.1"
[177,"summary"]	"Qt port of WebKit"
[177,"licenses"]	["GPLv3","LGPLv2.1+"]
[177,"maturity"]	"stable"
[177,"platforms"]	["Linux","Windows","MacOS"]
[177,"packages","source"]	"http://download.qt-project.org/official_releases/qt/5.1/5.1.1/submodules/qtwebkit-opensource-src-5.1.1.tar.xz"
[178,"name"]	"qtwebsockets"
[178,"display_name"]	"QtWebSockets"
[178,"summary"]	"Qt implementation of WebSockets client and server."
[178,"urls","vcs"]	"http://code.qt.io/cgit/qt/qtwebsockets.git/"
[178,"licenses"]	["LGPLv2.1+"]
[178,"platforms"]	["Linux","OS X","Windows","Android","iOS"]
[179,"name"]	"qtweetlib"
[179,"version"]	"0.5"
[179,"summary"]	"Library to access Twitter"
[179,"licenses"]	["GPLv2"]
[179,"maturity"]	"stable"
[179,"platforms"]	["Linux"]
[179,"packages","source"]	"https://github.com/minimoog/QTweetLib/archive/0.5.tar.gz"
[180,"name"]	"qtxlsx"
[180,"display_name"]	"Qt Xlsx"
[180,"version"]	"0.2.2"
[180,"summary"]	".xlsx file reader and writer for Qt5"
[180,"licenses"]	["MIT"]
[180,"maturity"]	"edge"
[180,"platforms"]	["Linux","Windows","OS X"]
[180,"packages","source"]	"https://github.com/dbzhang800/QtXlsxWriter/archive/v0.2.2.tar.gz"
[181,"name"]	"quazip"
[181,"version"]	"0.7"
[181,"summary"]	"Qt/C++ wrapper for ZIP/UNZIP package"
[181,"urls","vcs"]	"http://sourceforge.net/p/quazip/code/HEAD/tree/"
[181,"licenses"]	["LGPLv3+"]
[181,"maturity"]	"stable"
[181,"platforms"]	["Linux"]
[181,"packages","source"]	"http://sourceforge.net/projects/quazip/files/quazip/0.7/quazip-0.7.tar.gz/download"
[182,"name"]	"quickcross"
[182,"display_name"]	"Quick Cross"
[182,"version"]	"1.0.1"
[182,"summary"]	"QML Cross Platform Utility Library"
[182,"urls","vcs"]	"https://github.com/benlau/quickcross"
[182,"licenses"]	["Apache-2.0"]
[182,"maturity"]	"stable "
[182,"platforms"]	["Any"]
[182,"packages","source"]	"https://github.com/benlau/quickcross/archive/v1.0.1.zip"
[183,"name"]	"quickflux"
[183,"display_name"]	"Quick Flux"
[183,"version"]	"1.0.3"
[183,"summary"]	"Message Dispatcher / Queue for Qt/QML"
[183,"urls","vcs"]	"https://github.com/benlau/quickflux"
[183,"licenses"]	["Apache-2.0"]
[183,"maturity"]	"stable "
[183,"platforms"]	["Any"]
[183,"packages","source"]	"https://github.com/benlau/quickflux/archive/v1.0.3.zip"
[184,"name"]	"quickpromise"
[184,"display_name"]	"Quick Promise"
[184,"version"]	"1.0.3"
[184,"summary"]	"QML Promise Library"
[184,"urls","vcs"]	"https://github.com/benlau/quickpromise.git"
[184,"licenses"]	["Apache-2.0"]
[184,"maturity"]	"stable "
[184,"platforms"]	["Any"]
[184,"packages","source"]	"https://github.com/benlau/quickpromise/archive/v1.0.3.zip"
[185,"name"]	"quickproperties"
[185,"display_name"]	"QuickProperties"
[185,"version"]	"0.0.4"
[185,"summary"]	"QuickProperties is a C++/QML library for viewving and editing QObject properties in Qt5"
[185,"urls","vcs"]	"https://github.com/cneben/QuickQanava/tree/master/QuickProperties"
[185,"licenses"]	["GPLv3+"]
[185,"maturity"]	"alpha"
[185,"platforms"]	["Linux","Windows","Android"]
[185,"packages","source"]	"https://github.com/cneben/QuickQanava/archive/0.4.tar.gz"
[186,"name"]	"quickqanava"
[186,"display_name"]	"QuickQanava is a C++/QML graph drawing library for Qt5"
[186,"version"]	"0.0.4"
[186,"summary"]	"QuickQanava"
[186,"urls","vcs"]	"https://github.com/cneben/quickqanava"
[186,"licenses"]	["GPLv3+"]
[186,"maturity"]	"alpha"
[186,"platforms"]	["Linux","Windows","Android"]
[186,"packages","source"]	"https://github.com/cneben/QuickQanava/archive/0.4.tar.gz"
[187,"name"]	"qwt"
[187,"version"]	"6.1.0"
[187,"summary"]	"Widgets for Technical Applications"
[187,"urls","vcs"]	"http://qwt.svn.sourceforge.net/viewvc/qwt/"
[187,"licenses"]	["Qwt License 1.0"]
[187,"maturity"]	"stable"
[187,"platforms"]	["Linux"]
[187,"packages","source"]	"http://sourceforge.net/projects/qwt/files/qwt/6.1.0/qwt-6.1.0.tar.bz2/download"
[188,"name"]	"qwtplot3d"
[188,"version"]	"0.2.7"
[188,"summary"]	"3D plot widgets"
[188,"urls","vcs"]	"http://qwtplot3d.svn.sourceforge.net/viewvc/qwtplot3d/"
[188,"licenses"]	["zlib"]
[188,"maturity"]	"stable"
[188,"platforms"]	["Linux"]
[188,"packages","source"]	"http://sourceforge.net/projects/qwtplot3d/files/qwtplot3d/0.2.7/qwtplot3d-0.2.7.tgz/download"
[188,"packages","openSUSE","11.4","package_name"]	"libqwtplot3d0"
[188,"packages","openSUSE","11.4","repository","name"]	"openSUSE-11.4-Oss"
[189,"name"]	"qxmpp"
[189,"version"]	"0.8.0"
[189,"summary"]	"XMPP client and server library"
[189,"urls","vcs"]	"https://github.com/qxmpp-project/qxmpp"
[189,"licenses"]	["LGPL 2.1 or later"]
[189,"maturity"]	"stable"
[189,"platforms"]	["Cross-platform"]
[189,"packages","source"]	"https://github.com/qxmpp-project/qxmpp/archive/v0.8.0.tar.gz"
[190,"name"]	"qxorm"
[190,"version"]	"1.2.5"
[190,"summary"]	"Qt-based Object Relational Mapping (ORM)"
[190,"licenses"]	["GPLv3","Commercial"]
[190,"maturity"]	"stable"
[190,"platforms"]	["Linux","Windows","OSX"]
[190,"packages","source"]	"http://www.qxorm.com/version/QxOrm_1.2.5.zip"
[191,"name"]	"qyoto"
[191,"version"]	"4.11.1"
[191,"summary"]	"Mono bindings for core Qt libraries"
[191,"urls","vcs"]	"https://projects.kde.org/projects/kde/kdebindings/csharp/qyoto/repository"
[191,"licenses"]	["LGPLv2.1+"]
[191,"maturity"]	"stable"
[191,"platforms"]	["Linux"]
[191,"packages","source"]	"http://download.kde.org/stable/4.11.1/src/qyoto-4.11.1.tar.xz"
[192,"name"]	"snorenotify"
[192,"version"]	"0.7.0"
[192,"summary"]	"Snorenotify notification framework"
[192,"urls","vcs"]	"https://projects.kde.org/projects/playground/libs/snorenotify"
[192,"licenses"]	["LGPLv3"]
[192,"maturity"]	"stable"
[192,"platforms"]	["Linux","Windows","MacOS"]
[192,"packages","source"]	"http://download.kde.org/stable/snorenotify/0.7.0/src/snorenotify-0.7.0.tar.xz"
[193,"name"]	"solid"
[193,"display_name"]	"Solid"
[193,"version"]	"5.25.0"
[193,"summary"]	"Hardware integration and detection"
[193,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/solid/repository"
[193,"licenses"]	["LGPLv2.1+"]
[193,"maturity"]	"stable"
[193,"platforms"]	["Linux"]
[193,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/solid-5.25.0.tar.xz"
[194,"name"]	"sonnet"
[194,"display_name"]	"Sonnet"
[194,"version"]	"5.25.0"
[194,"summary"]	"Support for spellchecking"
[194,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/sonnet/repository"
[194,"licenses"]	["LGPLv2.1+"]
[194,"maturity"]	"stable"
[194,"platforms"]	["Linux"]
[194,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/sonnet-5.25.0.tar.xz"
[195,"name"]	"soprano"
[195,"version"]	"2.9.3"
[195,"summary"]	"Qt/C++ RDF framework"
[195,"urls","vcs"]	"http://quickgit.kde.org/?p=soprano.git&a=summary"
[195,"licenses"]	["LGPLv2.1+"]
[195,"maturity"]	"stable"
[195,"platforms"]	["Linux"]
[195,"packages","source"]	"http://sourceforge.net/projects/soprano/files/Soprano/2.9.3/soprano-2.9.3.tar.bz2/download"
[196,"name"]	"soqt"
[196,"version"]	"1.5.0"
[196,"summary"]	"Qt interface for 3D visualization library Coin"
[196,"licenses"]	["GPL"]
[196,"maturity"]	"stable"
[196,"platforms"]	["Linux","Windows","MacOS"]
[196,"packages","source"]	"https://bitbucket.org/Coin3D/coin/downloads/SoQt-1.5.0.tar.gz"
[196,"packages","openSUSE","11.4","package_name"]	"libSoQt20"
[196,"packages","openSUSE","11.4","repository","name"]	"openSUSE-11.4-Oss"
[197,"name"]	"sqlate"
[197,"version"]	"0.1.0"
[197,"summary"]	"type-safe template-based SQL support using Qt"
[197,"urls","vcs"]	"https://github.com/KDAB/sqlate/"
[197,"licenses"]	["LGPL"]
[197,"maturity"]	"stable"
[197,"platforms"]	["Linux","Windows","MacOS"]
[197,"packages","source"]	"https://github.com/KDAB/sqlate/archive/master.zip"
[198,"name"]	"tasks"
[198,"version"]	"1.2.1"
[198,"summary"]	"a simple single header library that allows async programming in Qt/C++ using tasks,continuations and resumable functions"
[198,"urls","vcs"]	"https://github.com/mhogomchungu/tasks.git"
[198,"licenses"]	["BSD"]
[198,"maturity"]	"stable"
[198,"platforms"]	["Linux","Windows","Mac OS"]
[198,"packages","source"]	"https://github.com/mhogomchungu/tasks/releases/download/1.2.1/tasks-1.2.1.tar.bz2"
[199,"name"]	"telepathy-qt"
[199,"version"]	"0.9.3"
[199,"summary"]	"Qt bindings for the Telepathy communications framework"
[199,"urls","vcs"]	"http://cgit.freedesktop.org/telepathy/telepathy-qt/"
[199,"licenses"]	["LGPLv2.1+"]
[199,"maturity"]	"stable"
[199,"platforms"]	["Linux"]
[199,"packages","source"]	"http://telepathy.freedesktop.org/releases/telepathy-qt/telepathy-qt-0.9.3.tar.gz"
[200,"name"]	"threadweaver"
[200,"display_name"]	"ThreadWeaver"
[200,"version"]	"5.25.0"
[200,"summary"]	"High-level multithreading framework"
[200,"urls","vcs"]	"https://projects.kde.org/projects/frameworks/threadweaver/repository"
[200,"licenses"]	["LGPLv2.1+"]
[200,"maturity"]	"stable"
[200,"platforms"]	["Linux"]
[200,"packages","source"]	"http://download.kde.org/stable/frameworks/5.25/threadweaver-5.25.0.tar.xz"
[201,"name"]	"treefrog"
[201,"version"]	"1.7.1"
[201,"summary"]	"Framework for developing web applications"
[201,"urls","vcs"]	"https://github.com/treefrogframework/treefrog-framework"
[201,"licenses"]	["BSD-3-Clause"]
[201,"maturity"]	"stable"
[201,"platforms"]	["Linux","Windows","OS X"]
[201,"packages","source"]	"http://sourceforge.net/projects/treefrog/files/src/treefrog-1.7.1.tar.gz/download"
[202,"name"]	"tufao"
[202,"version"]	"1.0.2"
[202,"summary"]	"An asynchronous web framework for C++ built on top of Qt"
[202,"urls","vcs"]	"https://github.com/vinipsmaker/tufao"
[202,"licenses"]	["Library: LGPLv2, Documentation and Examples: MIT"]
[202,"maturity"]	"stable"
[202,"platforms"]	["Linux","Windows","MacOS"]
[202,"packages","source"]	"https://github.com/vinipsmaker/tufao/archive/1.0.2.zip"
[203,"name"]	"vlc-qt"
[203,"display_name"]	"VLC-Qt"
[203,"version"]	"1.0.0"
[203,"summary"]	"VLC-Qt - a simple library to connect Qt application with libVLC"
[203,"urls","vcs"]	"https://github.com/vlc-qt/vlc-qt"
[203,"licenses"]	["LGPLv3"]
[203,"maturity"]	"stable"
[203,"platforms"]	["Linux","OS X","Windows"]
[203,"packages","source"]	"https://github.com/vlc-qt/vlc-qt/archive/1.0.0.tar.gz"
[204,"name"]	"openv2g"
[204,"display_name"]	"OpenV2G"
[204,"version"]	"0.9.3-lib"
[204,"summary"]	"OpenV2G, a DIN 70121 and ISO/IEC 15118-2 library"
[204,"packages","source"]	"http://gitlab.lan.trialog.com/openv2g/openv2g/uploads/54261b1cf873ba8ee93b6be7f63a90ef/v0.9.3-7-lib.tar.gz"
[204,"licenses"]	["LGPLv3"]
[204,"maturity"]	"stable"
[204,"platforms"]	["Linux"]
[205,"name"]	"tcanp-helper"
[205,"display_name"]	"TCanP Helper"
[205,"version"]	"2.1.2-lib"
[205,"summary"]	"Helper for TCanP, a high-level API for CAN communications over TCP"
[205,"packages","source"]	"http://gitlab.lan.trialog.com/vedecom/tcanp-helper/uploads/adfe227ce07060aa20fd33f3e8df8bab/v2.1.2-lib.tar.gz"
[205,"licenses"]	["VEDECOM", "TRIALOG"]
[205,"maturity"]	"stable"
[205,"platforms"]	["Linux"]
[206,"name"]	"http-parser-wrapper"
[206,"display_name"]	"HTTP Parser"
[206,"version"]	"2.7.1"
[206,"summary"]	"Qompoter wrapper for nodejs/http-parser"
[206,"urls","vcs"]	"https://github.com/qompoter/http-parser-wrapper.git"
[206,"packages","source"]	"https://github.com/qompoter/http-parser-wrapper/archive/v2.7.1.tar.gz"
[206,"licenses"]	["MIT"]
[206,"maturity"]	"stable"
[206,"platforms"]	["Linux", "OSX", "Windows"]
[207,"name"]	"qhttp-wrapper"
[207,"display_name"]	"QHttp"
[207,"version"]	"3.1.2"
[207,"summary"]	"Qompoter wrapper for azadkuh/qhttp and oliviermaridat/qhttp "
[207,"urls","vcs"]	"https://github.com/qompoter/qhttp-wrapper.git"
[207,"packages","source"]	"https://github.com/qompoter/http-parser-wrapper/archive/v3.1.2.tar.gz"
[207,"licenses"]	["MIT"]
[207,"maturity"]	"stable"
[207,"platforms"]	["Linux", "OSX", "Windows"]'

main
