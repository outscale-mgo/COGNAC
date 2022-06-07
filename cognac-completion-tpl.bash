#/usr/bin/env bash

____func_code____

_mk_profiles()
{
    cur=${COMP_WORDS[COMP_CWORD]}

    if [ -f ~/.osc/config.json ]; then
        PROFILES=$(cat ~/.osc/config.json | tr -d '\n:'  | sed 's/{[^{}]*}//g' | tr -d "{}\" " | sed 's/,/ /g')
    elif [ -f ~/.osc_sdk/config.json ]; then
        PROFILES=$(cat ~/.osc_sdk/config.json | tr -d '\n:'  | sed 's/{[^{}]*}//g' | tr -d "{}\" " | sed 's/,/ /g')
    fi
    for x in $PROFILES ; do echo --profile=$x ; done
}

_cognac()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case ${COMP_CWORD} in
        *)
            case ${prev} in
		____piped_call_list____)
		    eval ${prev}
		    ;;
                *)
                    COMPREPLY=($(compgen -W "--color --help ____call_list____" -- ${cur}))
		    ;;
            esac
            ;;
    esac
}

complete -F _cognac cognac
complete -F _cognac cognac-x86_64.AppImage

# thoses one are for debug
complete -F _cognac ./cognac
complete -F _cognac ./cognac-x86_64.AppImage
