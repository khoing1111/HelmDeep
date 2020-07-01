#!/bin/bash
_helmdeep_argcomplete() {
    ((lastw=${#COMP_WORDS[@]} -1))
    if [ $lastw == 1 ]; then
        COMPREPLY=($(compgen -W "setenv package drytest create dependency util release template lint show compare clone versioning" "${COMP_WORDS[lastw]}"))
    elif [ $lastw == 2 -a "${COMP_WORDS[1]}" == "setenv" ]; then
        COMPREPLY=($(compgen -W "dev staging prod" "${COMP_WORDS[lastw]}"))
    elif [ $lastw == 2 -a "${COMP_WORDS[1]}" == "versioning" ]; then
        COMPREPLY=($(compgen -W "major minor patch" "${COMP_WORDS[lastw]}"))
    elif [ $lastw == 2 -a "${COMP_WORDS[1]}" == "release" ]; then
        COMPREPLY=($(compgen -W "list history install uninstall upgrade rollback status" "${COMP_WORDS[lastw]}"))
    elif [ $lastw == 2 -a "${COMP_WORDS[1]}" == "dependency" ]; then
        COMPREPLY=($(compgen -W "update list" "${COMP_WORDS[lastw]}"))
    elif [ $lastw == 2 -a "${COMP_WORDS[1]}" == "util" ]; then
        COMPREPLY=($(compgen -W "import-template list-packages remove-packages" "${COMP_WORDS[lastw]}"))
    else
        # get all matching files and directories
        COMPREPLY=($(compgen -f  -- "${COMP_WORDS[$COMP_CWORD]}"))

        for ((ff=0; ff<${#COMPREPLY[@]}; ff++)); do
            [[ -d ${COMPREPLY[$ff]} ]] && COMPREPLY[$ff]+='/'
            [[ -f ${COMPREPLY[$ff]} ]] && COMPREPLY[$ff]+=' '
        done
    fi
}

complete -o nospace -o bashdefault -o default  -F _helmdeep_argcomplete "helmdeep"
