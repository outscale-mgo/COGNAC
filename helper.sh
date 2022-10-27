source ./config.sh

OSC_API_JSON=$(cat ./osc-api.json)

get_type2() {
    struct="$1"
    arg="$2"
    arg_info=$(jq .components.schemas.$struct.properties.$arg <<< $OSC_API_JSON)

    types=$(jq -r .type 2> /dev/null <<< $arg_info)
    have_type=$?
    if [ $have_type == 0 ]; then
	if [ "$types" == 'integer' ]; then
	    echo int
	    return 0
	elif [ "$types" == 'boolean' ]; then
	    echo bool
	    return 0
	elif [ "$types" == 'array' ]; then
	    sub_type=$(jq -r .items.type 2> /dev/null <<< $arg_info)
	    have_stype=$?
	    if [ $have_stype == 0 ]; then
		if [ "$sub_type" == 'string' ]; then
		    types="array string"
		elif [ "$sub_type" == 'integer' ]; then
		    types="array integer"
		elif [ "$sub_type" == 'null' ]; then
		    types="array ref $(json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4)"
		else
		    types="array ${sub_type}"
		fi
	    fi
	fi
	echo $types
    else
	echo ref $(json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4)
    fi
    return 0
}

get_type() {
    x=$2
    func=$1
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
	elif [ "$types" == 'array' ]; then
	    sub_ref=$(json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4 2> /dev/null)
	    have_sref=$?

	    if [ $have_sref == 0 ]; then
		types="array ref $sub_ref"
	    fi
	fi
	echo $types
    else
	echo ref $(json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4)
    fi
    return 0
}

alias to_snakecase="sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\L\2/g;s/[A-Z]/\L&/g'"
