#!/bin/sh

source "./helper.sh"

CALL_LIST_FILE=./call_list
CALL_LIST=$(cat $CALL_LIST_FILE)

for l in $CALL_LIST ;do
    snake_l=$(to_snakecase <<< $l)
    ARGS_LIST=$(json-search -s  ${l}Request ./osc-api.json | json-search -KR "properties" | tr -d '"' | sed 's/,/\n/g')

    echo "struct osc_${snake_l}_arg  {"

    for x in $ARGS_LIST ;do
	c_type="char *"
	snake_name=$(to_snakecase <<< "$x")

	#echo "get type: $func $x"
	t=$(get_type $x $l)
	if [ "$t" == 'int' -o "$t" == 'bool' ]; then
	    echo "        int is_set_${snake_name};"
	    c_type="int "
	elif [ "$t" == 'array integer' ]; then
	    echo "        char *${snake_name}_str;"
	    c_type="int *"
	fi
	echo "        ${c_type}${snake_name};"
    done
    echo "};"
done
