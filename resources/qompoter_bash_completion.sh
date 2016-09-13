#!/usr/bin/env bash

_qompoter()
{
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    local actions="inqlude install update export require jsonh"
    local blockingopts="-h -help --version"
    local commonopts="--no-color -V --verbose"
    local opts="-d --depth --inqlude-file --file -f --force --no-dev --no-qompote --repo --stable-only -v --vendor-dir ${blockingopts} ${commonopts}"
    local export_opts="--file --repo ${commonopts}"
    local inqlude_opts="--minify --search --inqlude-file ${commonopts}"
    local install_opts="-d --depth --inqlude-file --file -f --force --no-dev --no-qompote --repo --stable-only -v --vendor-dir ${commonopts}"
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
        install)
            COMPREPLY=( $(compgen -W "${install_opts}" -- ${cur}) )
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
