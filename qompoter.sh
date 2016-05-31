#!/usr/bin/env bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
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
	
	    action		Select an action: install, update, export, repo-export
	
	Options:
	    -r, --repo		Select a repository path as a location for dependency
	    			research. It is used in addition of the "repositories"
	    			filled in qompoter.json."
	    			E.g. "repo/repositories/vendor name/project name"
	        --vendor-dir	Pick another vendor directory as "vendor"
	        --qompoter-file	Pick another file as "qompoter.json"
	        --no-color	Do not enable color on output
	        --no-dev	Do not retrieve dev dependencies listed in "require-dev"
	    -V, --verbose	Enable more verbosity
	    -h, --help		Display this help
	    -v, --version	Display the version
	
	Examples:
	    Install all dependencies:
	    $PROGNAME install --repo /Project
	    
	    Install only nominal dependencies:
	    $PROGNAME install --no-dev --repo /Project
	    
	    Export existing dependencies:
	    $PROGNAME export
	
	EOF
}

version()
{
	cat <<- EOF
	Qompoter 0.2.0
	Dependency manager for C++/Qt by Fylhan
	EOF
}

createQompotePri()
{
	local qompotePri=$1
	echo '# $$setLibPath()' > $qompotePri
	echo '# Generate a lib path name depending of the OS and the arch' >> $qompotePri
	echo '# Export and return LIBPATH' >> $qompotePri
	echo 'defineReplace(setLibPath){' >> $qompotePri
	echo '    LIBPATH = lib' >> $qompotePri
	echo '    win32|win32-cross-mingw {' >> $qompotePri
	echo '        LIBPATH = $${LIBPATH}_windows' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '    else:unix {' >> $qompotePri
	echo '        LIBPATH = $${LIBPATH}_linux' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '' >> $qompotePri
	echo '    linux-g++-32 {' >> $qompotePri
	echo '        LIBPATH = $${LIBPATH}_32' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '    else:linux-g++-64 {' >> $qompotePri
	echo '        LIBPATH = $${LIBPATH}_64' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '    else {' >> $qompotePri
	echo '        contains(QMAKE_HOST.arch, x86_64) {' >> $qompotePri
	echo '            LIBPATH = $${LIBPATH}_64' >> $qompotePri
	echo '        }' >> $qompotePri
	echo '        else {' >> $qompotePri
	echo '            LIBPATH = $${LIBPATH}_32' >> $qompotePri
	echo '        }' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '' >> $qompotePri
	echo '    export(LIBPATH)' >> $qompotePri
	echo '    return($${LIBPATH})' >> $qompotePri
	echo '}' >> $qompotePri
	echo '' >> $qompotePri
	echo '# $$setLibName(lib name[, lib version])' >> $qompotePri
	echo '# Will add a "d" at the end of lib name in case of debug compilation, and "-version" if provided' >> $qompotePri
	echo '# Export VERSION, export and return LIBNAME' >> $qompotePri
	echo 'defineReplace(setLibName){' >> $qompotePri
	echo '    unset(LIBNAME)' >> $qompotePri
	echo '    LIBNAME = $$1' >> $qompotePri
	echo '    VERSION = $$2' >> $qompotePri
	echo '    CONFIG(debug,debug|release){' >> $qompotePri
	echo '        LIBNAME = $${LIBNAME}d' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '' >> $qompotePri
	echo '    export(VERSION)' >> $qompotePri
	echo '    export(LIBNAME)' >> $qompotePri
	echo '    return($${LIBNAME})' >> $qompotePri
	echo '}' >> $qompotePri
	echo '' >> $qompotePri
	echo '# $$getLibName(lib name)' >> $qompotePri
	echo '# Will add a "d" at the end of lib name in case of debug compilation, and "-version" if provided' >> $qompotePri
	echo '# Return lib name' >> $qompotePri
	echo 'defineReplace(getLibName){' >> $qompotePri
	echo '    ExtLibName = $$1' >> $qompotePri
	echo '    CONFIG(debug,debug|release){' >> $qompotePri
	echo '        ExtLibName = $${ExtLibName}d' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '' >> $qompotePri
	echo '    return($${ExtLibName})' >> $qompotePri
	echo '}' >> $qompotePri
	echo '' >> $qompotePri
	echo '# $$setBuildDir()' >> $qompotePri
	echo '# Generate a build dir depending of OS and arch' >> $qompotePri
	echo '# Export MOC_DIR, OBJECTS_DIR, UI_DIR, TARGET, LIBS' >> $qompotePri
	echo 'defineReplace(setBuildDir){' >> $qompotePri
	echo '    CONFIG(debug,debug|release){' >> $qompotePri
	echo '        MOC_DIR = debug' >> $qompotePri
	echo '        OBJECTS_DIR = debug' >> $qompotePri
	echo '        UI_DIR      = debug' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '    else {' >> $qompotePri
	echo '        MOC_DIR = release' >> $qompotePri
	echo '        OBJECTS_DIR = release' >> $qompotePri
	echo '        UI_DIR      = release' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '' >> $qompotePri
	echo '    win32|win32-cross-mingw{' >> $qompotePri
	echo '        MOC_DIR     = $${MOC_DIR}/build_windows' >> $qompotePri
	echo '        OBJECTS_DIR = $${OBJECTS_DIR}/build_windows' >> $qompotePri
	echo '        UI_DIR      = $${UI_DIR}/build_windows' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '    else:linux-g++-32{' >> $qompotePri
	echo '        MOC_DIR     = $${MOC_DIR}/build_linux_32' >> $qompotePri
	echo '        OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_32' >> $qompotePri
	echo '        UI_DIR      = $${UI_DIR}/build_linux_32' >> $qompotePri
	echo '        LIBS       += -L/usr/lib/gcc/i586-linux-gnu/4.9' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '    else:linux-g++-64{' >> $qompotePri
	echo '        MOC_DIR     = $${MOC_DIR}/build_linux_64' >> $qompotePri
	echo '        OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_64' >> $qompotePri
	echo '        UI_DIR      = $${UI_DIR}/build_linux_64' >> $qompotePri
	echo '        LIBS       += -L/usr/lib/gcc/x86_64-linux-gnu/4.9' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '    else:unix{' >> $qompotePri
	echo '        contains(QMAKE_HOST.arch, x86_64){' >> $qompotePri
	echo '            MOC_DIR     = $${MOC_DIR}/build_linux_64' >> $qompotePri
	echo '            OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_64' >> $qompotePri
	echo '            UI_DIR      = $${UI_DIR}/build_linux_64' >> $qompotePri
	echo '        }' >> $qompotePri
	echo '        else{' >> $qompotePri
	echo '            MOC_DIR     = $${MOC_DIR}/build_linux_32' >> $qompotePri
	echo '            OBJECTS_DIR = $${OBJECTS_DIR}/build_linux_32' >> $qompotePri
	echo '            UI_DIR      = $${UI_DIR}/build_linux_32' >> $qompotePri
	echo '        }' >> $qompotePri
	echo '    }' >> $qompotePri
	echo '    DESTDIR = $$OUT_PWD/$$OBJECTS_DIR' >> $qompotePri
	echo '' >> $qompotePri
	echo '    export(DESTDIR)' >> $qompotePri
	echo '    export(MOC_DIR)' >> $qompotePri
	echo '    export(OBJECTS_DIR)' >> $qompotePri
	echo '    export(UI_DIR)' >> $qompotePri
	echo '    export(LIBS)' >> $qompotePri
	echo '    return($TARGET)' >> $qompotePri
	echo '}' >> $qompotePri
	echo '' >> $qompotePri
}

prepareVendorDir()
{
  local vendorDir=$1
  mkdir -p ${vendorDir}
  createQompotePri ${vendorDir}/qompote.pri
  echo 'include($$PWD/qompote.pri)' > ${vendorDir}/vendor.pri
  echo '$$setLibPath()' >> ${vendorDir}/vendor.pri
}

downloadPackage()
{
  local repositoryPath=$1
  local vendorDir=$2
  local requireName=$3
  local requireVersion=$4
  local result=0
  local isSource=1
  if [[ "$requireVersion" == *"-lib" ]]; then
	isSource=0
  fi
  local projectName=`echo $requireName | cut -d'/' -f2`
  local requireBasePath=${repositoryPath}/${requireName}
  local requirePath=${requireBasePath}/${requireVersion}
  local requireLocalPath=${vendorDir}/${projectName}
  local qompoterPriFile=${requireLocalPath}/qompoter.pri


  echo "* ${requireName} ${requireVersion}"
  
  mkdir -p ${requireLocalPath}

  # Sources
  if [ "${isSource}" -eq 1 ]; then
    # Git
    if [ -d "${requireBasePath}/${projectName}.git" ] || [[ "$REPO_PATH" == *"github"* ]] || [[ "$REPO_PATH" == *"gitlab"* ]]; then
      echo "  Downloading sources from Git..."
      downloadPackageFromGit $repositoryPath $vendorDir $requireName $requireVersion \
	|| result=-1
    fi
    # Copy (also done if Git failed)
    if [ ! -d "${requireLocalPath}/.git" ]; then
      if [ "$result" == "-1" ]; then
        echo "  Error with Git. Downloading sources from scratch..."
        mkdir -p ${requireLocalPath}
      else
        echo "  Downloading sources..."
      fi
      downloadPackageFromCp ${requirePath} ${requireLocalPath} \
	&& result=0 \
	|| result=-1
    fi
  # Lib
  else
    echo "  Downloading lib..."
    downloadLibFromCp ${vendorDir} ${requirePath} ${requireLocalPath} \
      || result=-1
  fi
  
   if [ "$result" == "-1" ]; then
    echo -e "  ${FORMAT_FAIL}FAILLURE${FORMAT_END}"
    echo
    return -1
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
      >> ${LOG_FILENAME} 2>&1 \
      && return 0 \
      || return -1
  fi
  echo "  Error: no package found '${source}'"
  return -1
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
  echo "  Downloading sources from Git..."
  # Already exist: update
  if [ -d "${requireLocalPath}/.git" ]; then
    currentPath=`pwd`
    cd ${requireLocalPath}
    git fetch --all \
      >> ${LOG_FILENAME} 2>&1
    git checkout -f ${requireVersion} \
      >> ${LOG_FILENAME} 2>&1
    git reset --hard origin/${requireVersion} \
      >> ${LOG_FILENAME} 2>&1
    cd $currentPath
  # Else: clone
  else
    gitPath=${requireBasePath}/${projectName}.git
    if [[ "${repositoryPath}" == *"github"* ]] || [[ "${repositoryPath}" == *"gitlab"* ]]; then
	    gitPath=${requireBasePath}
    fi
    git clone -b ${requireVersion} ${gitPath} ${requireLocalPath} \
      >> ${LOG_FILENAME} 2>&1
  fi
  if [ ! -d "${requireLocalPath}/.git" ]; then
    gitError=-1
  fi
  return $gitError
}

exportAction()
{
  local vendorBackup=`date +"%Y-%m-%d"`_${VENDOR_DIR}.zip
  if [ -f "${vendorBackup}" ]; then
    rm ${vendorBackup}
  fi
  
  if [ -d "${VENDOR_DIR}" ]; then
    zip ${vendorBackup} -r ${VENDOR_DIR} \
      >> ${LOG_FILENAME} 2>&1
  else
    echo "Nothing to do: no '${VENDOR_DIR}' dir"
    return -1
  fi
}

installAction()
{
  local qomoterFiler=$1
  local vendorDir=$2
  if [ ! -f "${qomoterFiler}" ]; then
    echo "Qompoter could not find a '${qomoterFiler}' file in '${PWD}'"
    echo "To initialize a project, please create a '${qomoterFiler}' file as described in the https://github.com/Fylhan/qompoter/blob/master/docs/Qompoter-file.md"
    return -1
  fi
  
  prepareVendorDir ${vendorDir}
  
  cat ${qomoterFiler} \
   | jsonh \
   | egrep "\[\"repositories\",\".*\"\]" \
   | sed -r "s/\"//g;s/\[repositories,.*\]//g" \
   |
  {
	  while read repo; do
		  repositoryPath=${REPO_PATH}${repo}
	  done

	  cat ${qomoterFiler} \
	   | jsonh \
	   | egrep "\[\"require${INCLUDE_DEV}\",\".*\"\]" \
	   | sed -r "s/\"//g;s/\[require${INCLUDE_DEV},//g;s/\]	/ /g;s/dev-//g" \
	   | while read line; do
	      downloadPackage ${REPO_PATH} ${vendorDir} $line \
		|| return -1
	  done
  }
}

jsonhAction()
{
  local qompoterFile=$1
  cat ${qompoterFile} | jsonh
}

updateAction()
{
  echo "Not implemented yet"; 
  return -1
}

repoExportAction()
{
  echo "Not implemented yet"; 
  return -1
}


cmdline()
{
  ACTION=
  LOG_FILENAME=qompoter.log
  QOMPOTER_FILENAME=qompoter.json
  VENDOR_DIR=vendor
  REPO_PATH=
  INCLUDE_DEV=(-dev)?
  IS_VERBOSE=0

  if [ "$#" -lt "1" ]; then
    echo -e "${FORMAT_FAIL}FAILLURE${FORMAT_END} missing arguments"
    usage
    exit -1
  fi
  while [ "$1" != "" ]; do
  case $1 in
    --qompoter-file )
      shift
      QOMPOTER_FILENAME=$1
      shift
      ;;
    -r | --repo )
      shift
      REPO_PATH=$1
      shift
      ;;
    --vendor-dir )
      shift
      VENDOR_DIR=$1
      shift
      ;;
    --no-dev )
      INCLUDE_DEV=
      shift
      ;;
     --no-color )
      FORMAT_OK=
      FORMAT_FAIL=
      FORMAT_END=
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
    -v | --version )
      version
      exit 0
      ;;
    *)
      if [ "${ACTION}" == ""  ]; then
        ACTION=$1
        shift
	else
        echo -e "${FORMAT_FAIL}FAILLURE${FORMAT_END} unknwon argument '$1'"
        usage
        exit -1
      fi
      ;;
  esac
  done
  
  if [ "${ACTION}" == ""  ]; then
    echo -e "${FORMAT_FAIL}FAILLURE${FORMAT_END} missing action"
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
 
   
  if [ "${ACTION}" == "export" ]; then
    exportAction ${VENDOR_DIR} \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILLURE${FORMAT_END}"
  elif [ "${ACTION}" == "install" ]; then
    installAction ${QOMPOTER_FILENAME} ${VENDOR_DIR} \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILLURE${FORMAT_END}"
  elif [ "${ACTION}" == "jsonh" ]; then
    jsonhAction ${QOMPOTER_FILENAME} \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILLURE${FORMAT_END}"
  elif [ "${ACTION}" == "repo-export" ]; then
    repoExportAction \
      && echo -e "${FORMAT_OK}done${FORMAT_END}" \
      || echo -e "${FORMAT_FAIL}FAILLURE${FORMAT_END}"
  else
    echo -e "${FORMAT_FAIL}FAILLURE${FORMAT_END} Unknown action '${ACTION}'"
  fi
}
main