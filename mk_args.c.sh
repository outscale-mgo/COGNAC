#!/bin/sh

source "./helper.sh"

ARGS_LIST=$(cat arguments-list.json)

for x in $ARGS_LIST ;do
    c_type="char *"
    snake_name=$(to_snakecase <<< $x)

    t=$(get_type $x)
    if [ $t == 'int' -o $t == 'bool' ]; then
	echo "        int is_set_${snake_name};"
	c_type="int "
    fi
    echo -n "        $c_type"
    echo -n $snake_name
    echo ';'
done
