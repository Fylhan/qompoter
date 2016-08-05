#!/usr/bin/env bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly PROGVERSION="v0.2.2"
readonly ARGS="$@"
FORMAT_OK="\e[1;32m"
FORMAT_FAIL="\e[1;31m"
FORMAT_END="\e[0m"

#######################
# JSON.H              #
#######################

throw () {
  echo "$*" >&2
  exit 1
}

BRIEF=0
LEAFONLY=0
PRUNE=0

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

awk_egrep () {
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

tokenize () {
  local GREP
  local ESCAPE
  local CHAR

  if echo "test string" | egrep -ao --color=never "test" &>/dev/null
  then
    GREP='egrep -ao --color=never'
  else
    GREP='egrep -ao'
  fi

  if echo "test string" | egrep -o "test" &>/dev/null
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

  $GREP "$STRING|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
}

parse_array () {
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

parse_object () {
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

parse_value () {
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

parse () {
  read -r token
  parse_value
  read -r token
  case "$token" in
    '') ;;
    *) throw "EXPECTED EOF GOT $token" ;;
  esac
}

#if ([ "$0" = "$BASH_SOURCE" ] || ! [ -n "$BASH_SOURCE" ]);
#then
#  parse_options "$@"
#  tokenize | parse
#fi

jsonh()
{
  parse_options "$@"
  tokenize | parse
}


#######################
# QOMPOTER            #
#######################

usage()
{
	cat <<- EOF
	Usage: $PROGNAME [action] [ --repo <repo> | other options ]
	
	    action            Select an action:
	                      install, update, export, require, repo-export
	
	Options:
	    -d, --depth       Depth of the recursivity in the searching of
	                      subpackages
	
	    -f, --file        Pick another file as "qompoter.json"
	
	    -l, --list        List elements depending of the action
	                      Supported action is: "require"
	
	        --no-color    Do not enable color on output
	
	        --no-dev      Do not retrieve dev dependencies listed
	                      in "require-dev"
	
	    -r, --repo        Select a repository path as a location for
	                      dependency research. It is used in addition
	                      of the "repositories" provided in
	                      "qompoter.json".
	                      E.g. "repo/repositories/<vendor name>/<project name>"
	
	    -v, --vendor-dir  Pick another vendor directory as "vendor"
	
	    -V, --verbose     Enable more verbosity
	
	    -h, --help        Display this help
	
	        --version     Display the version
	
	Examples:
	    Install all dependencies:
	    $PROGNAME install --repo /Project
	    
	    Install only nominal dependencies:
	    $PROGNAME install --no-dev --repo /Project
	    
	    List required dependencies for this project:
	    $PROGNAME require --list
	    
	    Export existing dependencies:
	    $PROGNAME export
	
	EOF
}

version()
{
	cat <<- EOF
	Qompoter ${PROGVERSION}
	Dependency manager for C++/Qt by Fylhan
	EOF
}

createQompotePri()
{
	local qompotePri=$1
	cat << 'EOF' > ${qompotePri}
# $$setLibPath()
# Generate a lib path name depending of the OS and the arch
# Export and return LIBPATH
defineReplace(setLibPath){
    LIBPATH = lib
    win32|win32-cross-mingw {
	LIBPATH = $${LIBPATH}_windows
    }
    else:unix {
	LIBPATH = $${LIBPATH}_linux
    }

    linux-g++-32 {
	LIBPATH = $${LIBPATH}_32
    }
    else:linux-g++-64 {
	LIBPATH = $${LIBPATH}_64
    }
    else:linux-arm-gnueabi-g++ {
	LIBPATH = $${LIBPATH}_arm-gnueabi
    }
    else {
	contains(QMAKE_HOST.arch, x86_64) {
		LIBPATH = $${LIBPATH}_64
	}
	else {
		LIBPATH = $${LIBPATH}_32
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

    win32|win32-cross-mingw{
	MOC_DIR     = $${MOC_DIR}/build_windows
	OBJECTS_DIR = $${OBJECTS_DIR}/build_windows
	UI_DIR      = $${UI_DIR}/build_windows
    }
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
  mkdir -p ${vendorDir}
  createQompotePri ${vendorDir}/qompote.pri
  echo 'include($$PWD/qompote.pri)' > ${vendorDir}/vendor.pri
  echo 'INCLUDEPATH += $$PWD' >> ${vendorDir}/vendor.pri
  echo '$$setLibPath()' >> ${vendorDir}/vendor.pri
}

downloadPackage()
{
  local repositoryPath=$1
  local vendorDir=$2
  local vendorName=$3
  local projectName=$4
  local requireName=$vendorName/$projectName
  local requireVersion=$5
  local result=0
  local isSource=1
  if [[ "$requireVersion" == *"-lib" ]]; then
    isSource=0
  fi
  local requireBasePath=${repositoryPath}/${requireName}
  local requirePath=${requireBasePath}/${requireVersion}
  local requireLocalPath=${vendorDir}/${projectName}
  local qompoterPriFile=${requireLocalPath}/qompoter.pri


  echo "* ${requireName} ${requireVersion}"
  
  mkdir -p ${requireLocalPath}

  # Sources
  if [ "${isSource}" -eq 1 ]; then
    # Git
    if [ -d "${requireBasePath}/${projectName}.git" ] || [[ "${requireBasePath}" == *"github"* ]] || [[ "${requireBasePath}" == *"gitlab"* ]] || [[ "${requireBasePath}" == *"framagit"* ]]; then
      echo "  Downloading sources from Git..."
      downloadPackageFromGit $repositoryPath $vendorDir $requireName $requireVersion \
	|| result=1
    fi
    # Copy (also done if Git failed)
    if [ ! -d "${requireLocalPath}/.git" ]; then
      if [ "$result" == "1" ]; then
        echo "  Error with Git. Downloading sources from scratch..."
        mkdir -p ${requireLocalPath}
      else
        echo "  Downloading sources..."
      fi
      downloadPackageFromCp ${requirePath} ${requireLocalPath} \
	&& result=0 \
	|| result=1
    fi
  # Lib
  else
    echo "  Downloading lib..."
    downloadLibFromCp ${vendorDir} ${requirePath} ${requireLocalPath} \
      || result=-1
  fi
  
  # FAILURE
  if [ "$result" == "1" ]; then
    echo -e "  ${FORMAT_FAIL}FAILURE${FORMAT_END}"
    echo
    return 1
  # DONE
  else
    # Qompoter.pri
    if [ -f "${qompoterPriFile}" ]; then
      cat ${qompoterPriFile} >> ${vendorDir}/vendor.pri
    else
      echo "  Warning: no 'qompoter.pri' found for this package"
    fi
    
    echo -e "  ${FORMAT_OK}done${FORMAT_END}"
    echo
  fi
  return 0
}

downloadPackageFromCp()
{
  local source=$1
  local target=$2
  
  if [ -d "${source}" ]; then
    cp -rf ${source}/* ${target} \
      >> ${LOG_FILENAME} 2>&1
    return
  fi
  rm -rf ${target}
  echo "  Error: no package found '${source}'"
  return 1
}

downloadLibFromCp()
{
  local vendorDir=$1
  local source=$2
  local target=$3
  
  cp -rf ${source}/lib_* ${vendorDir} \
      >> ${LOG_FILENAME} 2>&1
  cp -rf ${source}/include ${target} \
      >> ${LOG_FILENAME} 2>&1
  cp -rf ${source}/qompoter.* ${target} \
      >> ${LOG_FILENAME} 2>&1
  return 0
}

downloadPackageFromGit()
{
  local repositoryPath=$1
  local vendorDir=$2
  local requireName=$3
  local requireVersion=$4
  local requireLocalPath=${vendorDir}/${projectName}
  local isSource=1
  local gitError=0
  # Already exist: update
  if [ -d "${requireLocalPath}/.git" ]; then
    currentPath=`pwd`
    cd ${requireLocalPath} || ( echo "  Error: can not go to ${requireLocalPath}" ; echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END}" ; exit -1)
    ilog "  Retrieve data from Git repository"
    git fetch --all \
      >> ${LOG_FILENAME} 2>&1
    if [ -z "`git status | grep \"${requireVersion}\"`" ]; then
      ilog "  Checkout to '${requireVersion}'"
      if ! git checkout -f ${requireVersion} >> ${LOG_FILENAME} 2>&1; then
        ilog "  Oups, it does not exist"
        return 2
      fi
    fi
    ilog "  Reset any local modification just to be sure"
    git reset --hard origin/${requireVersion} \
      >> ${LOG_FILENAME} 2>&1
    cd $currentPath || ( echo "  Error: can not go back to ${currentPath}" ; echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END}" ; exit -1)
  # Else: clone
  else
    gitPath=${requireBasePath}/${projectName}.git
    if [[ "${repositoryPath}" == *"github"* ]] || [[ "${repositoryPath}" == *"gitlab"* ]] || [[ "${requireBasePath}" == *"framagit"* ]]; then
      gitPath=${requireBasePath}
    fi
    git clone -b ${requireVersion} ${gitPath} ${requireLocalPath} \
      >> ${LOG_FILENAME} 2>&1
  fi
  if [ ! -d "${requireLocalPath}/.git" ]; then
    gitError=1
  fi
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

getProjectRequires()
{
  local qompoterFile=$1
  echo `cat ${qompoterFile} \
   | jsonh \
   | egrep "\[\"require${INCLUDE_DEV}\",\".*\"\]" \
   | sed -r "s/\"//g;s/\[require${INCLUDE_DEV},//g;s/\]	/ /g;s/dev-//g" \
   | tr ' ' '/'`
}

getProjectName()
{
  cat ${qompoterFile} \
   | jsonh \
   | egrep "\[\"name\"\]" \
   | sed -e 's/"//g;s/\[name\]\s*//;s/.*\///'
}

getRelatedRepository()
{
  local qompoterFile=$1
  local requireName=$2/$3
  local repositoryPathFromQompoterFile=`cat ${qompoterFile} \
   | jsonh \
   | egrep "\[\"repositories\",\"${requireName}\"\]" \
   | sed -r "s/\"//g;s/\[repositories,.*\]\t*//g"`
  if [ "${repositoryPathFromQompoterFile}" != "" ]; then
    echo ${repositoryPathFromQompoterFile}
  else
    echo ${REPO_PATH}
  fi
}

downloadQompoterFilePackages()
{
  local qompoterFile=$1
  local vendorDir=$2
  
  for packageInfo in `getProjectRequires ${qompoterFile}`; do
      local vendorName=`echo ${packageInfo} | cut -d'/' -f1`
      local projectName=`echo ${packageInfo} | cut -d'/' -f2`
      local version=`echo ${packageInfo} | cut -d'/' -f3`
      test "${DOWNLOADED_PACKAGES#*$projectName}" != "$DOWNLOADED_PACKAGES" && continue
      local repo=`getRelatedRepository ${qompoterFile} ${vendorName} ${projectName}`
      downloadPackage ${repo} ${vendorDir} ${vendorName} ${projectName} ${version} \
        || return 1
      DOWNLOADED_PACKAGES="${DOWNLOADED_PACKAGES} ${projectName}"
      if [ -f "${vendorDir}/${projectName}/qompoter.json" ]; then
        NEW_SUBPACKAGES="${NEW_SUBPACKAGES} ${vendorDir}/${projectName}/qompoter.json"
      fi
  done
}

updateVendorDirFromQompoterFile()
{
  local qompoterFile=$1
  if [ -f "${qompoterFile}" ]; then
    local vendorDirFromQompoterFile=`cat ${qompoterFile} \
     | jsonh \
     | egrep "\[\"vendor-dir\"\]" \
     | sed -r "s/\"//g;s/\[vendor-dir\]//g"`
    if [ "${vendorDirFromQompoterFile}" != "" ]; then
      VENDOR_DIR=${vendorDirFromQompoterFile}
    fi
  fi
}

exportAction()
{
  local qompoterFile=$1

  checkQompoterFile ${qompoterFile} --quiet || return 100
  local vendorBackup=`date +"%Y-%m-%d"`_`getProjectName ${qompoterFile}`_${VENDOR_DIR}.zip
  if [ -f "${vendorBackup}" ]; then
    rm ${vendorBackup}
  fi
  
  if [ -d "${VENDOR_DIR}" ]; then
    zip ${vendorBackup} -r ${VENDOR_DIR} \
      >> ${LOG_FILENAME} 2>&1
    echo "Exported to ${vendorBackup}"
  else
    echo "Nothing to do: no '${VENDOR_DIR}' dir"
    return 0
  fi
}

installAction()
{
  local qompoterFile=$1
  local vendorDir=$2
  
  checkQompoterFile ${qompoterFile} || return 100
  prepareVendorDir ${vendorDir}
  
  local depth=0
  while [ "$depth" -lt "$DEPTH_SIZE" ] && [ -n "${NEW_SUBPACKAGES}" ]; do
    depth=$((depth+1))
    local newSubpackages=${NEW_SUBPACKAGES}
    NEW_SUBPACKAGES=""
    for subQompoterFile in ${newSubpackages}; do
      downloadQompoterFilePackages ${subQompoterFile} ${vendorDir} \
        || return 1
    done
    if [ "$depth" == "$DEPTH_SIZE" ] && [ -n "${NEW_SUBPACKAGES}" ]; then
      echo -e "${FORMAT_FAIL}WARNING${FORMAT_END} There are still packages to download but maximal recursive depth of $DEPTH_SIZE have been reached."
    fi
  done
}

jsonhAction()
{
  local qompoterFile=$1
  cat ${qompoterFile} | jsonh
}

updateAction()
{
  echo "Not implemented yet"; 
  return 1
}

requireListAction()
{
  local qompoterFile=$1
  
  checkQompoterFile ${qompoterFile} || return 100
  for packageInfo in `getProjectRequires ${qompoterFile}`; do
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
  echo "Not implemented yet"; 
  return 1
}

ilog()
{
  if [ "$IS_VERBOSE" == "1" ]; then
    echo "$@"
  fi
}

cmdline()
{
  ACTION=
  SUB_ACTION=
  LOG_FILENAME=qompoter.log
  QOMPOTER_FILENAME=qompoter.json
  VENDOR_DIR=vendor
  REPO_PATH=
  INCLUDE_DEV=(-dev)?
  IS_VERBOSE=0
  DEPTH_SIZE=10
  DOWNLOADED_PACKAGES=
  NEW_SUBPACKAGES=${QOMPOTER_FILENAME}

  if [ "$#" -lt "1" ]; then
    echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END} missing arguments"
    usage
    exit -1
  fi
  while [ "$1" != "" ]; do
  case $1 in
    -d | --depth )
      shift
      DEPTH_SIZE=$1
      shift
      ;;
    -f | --file )
      shift
      QOMPOTER_FILENAME=$1
      NEW_SUBPACKAGES=${QOMPOTER_FILENAME}
      shift
      ;;
    -l | --list )
      if [ "${ACTION}" == "require"  ]; then
        SUB_ACTION="list"
      else
        echo "Ignore flag --list for action ${ACTION}"
      fi
      shift
      ;;
    --no-color )
      FORMAT_OK=
      FORMAT_FAIL=
      FORMAT_END=
      shift
      ;;
    --no-dev )
      INCLUDE_DEV=
      shift
      ;;
    -r | --repo )
      shift
      REPO_PATH=$1
      shift
      ;;
    -v | --vendor-dir )
      shift
      VENDOR_DIR=$1
      shift
      ;;
    -V | --verbose )
      IS_VERBOSE=1
      shift
      ;;
    -h | --help )
      usage
      exit 0
      ;;
    --version )
      version
      exit 0
      ;;
    *)
      if [ "${ACTION}" == ""  ]; then
        ACTION=$1
        shift
	else
        echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END} unknwon argument '$1'"
        usage
        exit -1
      fi
      ;;
  esac
  done
  
  if [ "${ACTION}" == ""  ]; then
    echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END} missing action"
    usage
    exit -1
  fi

  VENDOR_PATH=${PWD}/${VENDOR_DIR}
  return 0
}

main()
{
  cmdline $ARGS
  if [ -f "${LOG_FILENAME}" ]; then
    rm ${LOG_FILENAME}
  fi
  touch ${LOG_FILENAME}
    
  echo "Qompoter"
  echo "======== ${ACTION}"
  echo
 
  updateVendorDirFromQompoterFile ${QOMPOTER_FILENAME}
  if [ "${ACTION}" == "export" ]; then
    exportAction ${QOMPOTER_FILENAME} ${VENDOR_DIR} \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END}"
  elif [ "${ACTION}" == "install" ]; then
    installAction ${QOMPOTER_FILENAME} ${VENDOR_DIR} \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END}"
  elif [ "${ACTION}" == "jsonh" ]; then
    jsonhAction ${QOMPOTER_FILENAME} \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END}"
  elif [ "${ACTION}" == "require" ]; then
    if [ "${SUB_ACTION}" == "list" ]; then
    requireListAction ${QOMPOTER_FILENAME} \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END}"
    else
      requireAction ${QOMPOTER_FILENAME} \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END}"
    fi
  elif [ "${ACTION}" == "repo-export" ]; then
    repoExportAction \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END}"
  elif [ "${ACTION}" == "update" ]; then
    updateAction ${QOMPOTER_FILENAME} ${VENDOR_DIR} \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END}"
  else
    echo -e "${FORMAT_FAIL}FAILURE${FORMAT_END} Unknown action '${ACTION}'"
  fi
  
  if [ "$IS_VERBOSE" == "0" ]; then
    rm ${LOG_FILENAME}
  fi
}
main