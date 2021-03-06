source ./config.sh

OSC_API_JSON=$(cat ./osc-api.json)

get_type() {
    x=$1
    func=$2
    arg_info=$(json-search ${func}Request <<< $OSC_API_JSON | json-search $x)
    types=$(json-search -R type 2> /dev/null <<< $arg_info)
    have_type=$?
    if [ $have_type == 0 ]; then
	if [ "$types" == 'integer' ]; then
	    echo int
	    return 0
	elif [ "$types" == 'boolean' ]; then
	    echo bool
	    return 0
	fi
	echo $types
    else
	json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4

    fi
    return 0
}

alias to_snakecase="sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\L\2/g;s/[A-Z]/\L&/g'"
