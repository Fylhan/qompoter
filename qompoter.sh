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
  echo " --repo		Distant Repository to use."
  echo " --no-dev	Don't retrieve dev dependencies."
  echo " --help		Display this help."
  echo ""
  echo "Example: qompoter --repo /Project"
}

downloadRequire()
{
  repositoryPath=$1
  vendorDir=$2
  requireName=$3
  requireVersion=$4
  isSource=$5

  echo "* ${requireName} ${requireVersion}"
  requireBasePath=${repositoryPath}/${requireName}
  requirePath=${requireBasePath}/${requireVersion}
  requireLocalPath=${vendorDir}/${requireName}
  mkdir -p ${requireLocalPath}
  # Git
  # cp or wget with a structure
  # cp or wget without structure
  if [ "${isSource}" -eq 1 ]; then
    if [ -d "${requireBasePath}.git" ]; then
      # TODO remove dev- in requireVersion
      git clone -b ${requireVersion} ${requireBasePath}.git
    else
      cp -rf ${requirePath}/src/* ${requireLocalPath}
    fi
    qompoterPriFile=${requireLocalPath}/qompoter.pri
  else
    cp -rf ${requirePath}/lib_* ${vendorDir}
    cp -rf ${requirePath}/include ${requireLocalPath}
    qompoterPriFile=${requireLocalPath}/include/qompoter.pri
  fi
  cat ${qompoterPriFile} >> ${vendorDir}/vendor.pri
  echo "  done"
  echo
}

if [ "$#" -lt 2 ]; then
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

if [ "$repositoryPath" = "" ]; then
  echo "Empty parameter"
  usage
  exit -1
fi

echo 'Qompoter'
echo '========'
echo

vendorDir=${PWD}/vendor
mkdir -p ${vendorDir}
echo 'include($$PWD/../common.pri)' > ${vendorDir}/vendor.pri
echo '$$setLibPath()' >> ${vendorDir}/vendor.pri

#cat qompoter.config | while read line; do
#    downloadRequire $repositoryPath $vendorDir $line
#done

cat qompoter.json \
 | jsonh \
 | egrep "\[\"require${dev}\",\".*\"\]" \
 | sed -r "s/\"//g;s/\[require${dev},//g;s/\]	/ /g;s/-lib/ 0/g" \
 | while read line; do
    downloadRequire $repositoryPath $vendorDir $line 1
done