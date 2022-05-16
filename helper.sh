get_type() {
    x=$1
    types=$(json-search -s Request osc-api.json | json-search $x | json-search type 2> /dev/null)
    have_type=$?
    if [ $have_type == 0 ]; then
	types=$(tr -d ',[]"' <<< $types | sort | uniq)
	nb_args=$(wc -w <<< $types)

	if [ $nb_args == 1 ]; then
	    if [ $types == 'integer' ]; then
		echo int
		return 0
	    elif [ $types == 'boolean' ]; then
		echo bool
		return 0
	    fi
	fi
    fi
    echo 'unknow'
    return 0
}

alias to_snakecase="sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\L\2/g;s/[A-Z]/\L&/g'"
