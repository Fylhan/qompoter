#!/usr/bin/env bash

_qompoter()
{
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    local actions="init inqlude install inspect update export require jsonh md5sum"
    local blockingopts="-h -help --version"
    local commonopts="--no-color -V -VV -VVV --verbose"
    local opts="-d --depth --inqlude-file --file -f --force --no-dev --no-qompote -r --repo --stable-only -v --vendor-dir ${blockingopts} ${commonopts}"
    local export_opts="--file -r --repo -v --vendor ${commonopts}"
    local inqlude_opts="--minify --search --inqlude-file ${commonopts}"
    local inspect_opts="--file -v --vendor-dir ${commonopts}"
    local install_opts="-d --depth --inqlude-file --file -f --force --no-dev --no-qompote -r --repo --stable-only -v --vendor-dir ${commonopts}"
    local md5sum_opts="-v --vendor-dir ${commonopts}"
    local require_opts="--file -l --list ${commonopts}"

    case $prev in
        --file|\
        --inqlude-file|\
        -r|--repo|\
        -v|--vendor-dir)
            _filedir
            return 0
            ;;
        -h|--help|\
        --version)
            return
            ;;
        export)
            COMPREPLY=( $(compgen -W "${export_opts}" -- ${cur}) )
            return 0
            ;;
        inqlude)
            COMPREPLY=( $(compgen -W "${inqlude_opts}" -- ${cur}) )
            return 0
            ;;
        inspect)
            COMPREPLY=( $(compgen -W "${inspect_opts}" -- ${cur}) )
            return 0
            ;;
        install)
            COMPREPLY=( $(compgen -W "${install_opts}" -- ${cur}) )
            return 0
            ;;
        md5sum)
            COMPREPLY=( $(compgen -W "${md5sum_opts}" -- ${cur}) )
            return 0
            ;;
        require)
            COMPREPLY=( $(compgen -W "${require_opts}" -- ${cur}) )
            return 0
            ;;
    esac

    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    else
        COMPREPLY=( $(compgen -W "${actions}" -- ${cur}) )
        return 0
    fi
}
complete -F _qompoter qompoter
