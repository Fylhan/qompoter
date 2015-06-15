#!/usr/bin/env bash

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
  echo "usage: qompoter [ --repo <repo> | --help ]"
  echo ""
  echo " -r, --repo	Select a repository path as a location for dependency"
  echo "		research. It is used in addition of the \"repositories\""
  echo "		field in qompoter.json."
  echo "		E.g. \"repo/repositories/vendor name/project name\""
  echo " --vendor-dir	Pick another vendor directory as \"vendor\""
  echo " --no-dev	Don't retrieve dev dependencies listed in \"require-dev\""
  echo " -h, --help	Display this help"
  echo " -v, --version	Display the Qompoter version"
  echo ""
  echo "Example: qompoter --repo /Project"
}

version()
{
  echo "Qompoter 0.1.0"
  echo "Dependency manager for C++/Qt by Fylhan"
}

createQompotePri()
{
	qompotePri=$1
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
	vendorDir=$1
	mkdir -p ${vendorDir}
	createQompotePri ${vendorDir}/qompote.pri
	echo 'include($$PWD/qompote.pri)' > ${vendorDir}/vendor.pri
	echo '$$setLibPath()' >> ${vendorDir}/vendor.pri
}

downloadRequire()
{
  repositoryPath=$1
  vendorDir=$2
  requireName=$3
  requireVersion=$4
  isSource=1
  if [[ "$requireVersion" == *"-lib" ]]; then
	isSource=0
  fi

  echo "* ${requireName} ${requireVersion}"
  projectName=`echo $requireName | cut -d'/' -f2`
  requireBasePath=${repositoryPath}/${requireName}
  requirePath=${requireBasePath}/${requireVersion}
  requireLocalPath=${vendorDir}/${projectName}
  mkdir -p ${requireLocalPath}

  # Sources
  if [ "${isSource}" -eq 1 ]; then
    gitError=0
    # Git
    if [ -d "${requireBasePath}/${projectName}.git" ] || [[ "$repositoryPath" == *"github"* ]]; then
      echo "  Downloading sources from Git..."
      # Already exist: update
      if [ -d "${requireLocalPath}/.git" ]; then
	currentPath=`pwd`
	cd ${requireLocalPath}
	git fetch --all
	git checkout -f ${requireVersion}
	git reset --hard origin/${requireVersion}
	cd $currentPath
      # Else: clone
      else
        gitPath=${requireBasePath}/${projectName}.git
	if [[ "$repositoryPath" == *"github"* ]]; then
		gitPath=${requireBasePath}
	fi
	git clone -b ${requireVersion} ${gitPath} ${requireLocalPath}
      fi
      if [ ! -d "${requireLocalPath}/.git" ]; then
        gitError=1
      fi
    fi
    # FS (or Git failed)
    if [ ! -d "${requireLocalPath}/.git" ]; then
      if [ "$gitError" -eq 1 ]; then
        echo "  Error with Git. Downloading sources from scratch..."
        mkdir -p ${requireLocalPath}
      else
        echo "  Downloading sources..."
      fi
      cp -rf ${requirePath}/* ${requireLocalPath}
    fi
    qompoterPriFile=${requireLocalPath}/qompoter.pri
  # Lib
  else
    echo "  Downloading lib..."
    cp -rf ${requirePath}/lib_* ${vendorDir}
    cp -rf ${requirePath}/include ${requireLocalPath}
    cp -rf ${requirePath}/qompoter.* ${requireLocalPath}
    qompoterPriFile=${requireLocalPath}/qompoter.pri
  fi
  
  # Qompoter.pri
  if [ -f "${qompoterPriFile}" ]; then
	cat ${qompoterPriFile} >> ${vendorDir}/vendor.pri
  else
	echo "  Warning: there is no qompoter.pri file"
  fi
  
  echo "  done"
  echo
}

dev=(-dev)?
vendorDir=${PWD}/vendor
repositoryPath=
while [ "$1" != "" ]; do
case $1 in
  -r | --repo )
    shift
    repositoryPath=$1
    shift
    ;;
  -vd | --vendor-dir )
    shift
    vendorDir=$1
    shift
    ;;
  -nd | --no-dev )
    dev=
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
    echo "Unknown parameter $1"
    usage
    exit -1
    ;;
esac
done

echo 'Qompoter'
echo '========'
echo

prepareVendorDir $vendorDir

cat qompoter.json \
 | jsonh \
 | egrep "\[\"repositories\",\".*\"\]" \
 | sed -r "s/\"//g;s/\[repositories,.*\]//g" \
 |
{
	while read repo; do
		repositoryPath=${repositoryPath}${repo}
	done

	cat qompoter.json \
	 | jsonh \
	 | egrep "\[\"require${dev}\",\".*\"\]" \
	 | sed -r "s/\"//g;s/\[require${dev},//g;s/\]	/ /g;s/dev-//g" \
	 | while read line; do
	    downloadRequire $repositoryPath $vendorDir $line
	done
}