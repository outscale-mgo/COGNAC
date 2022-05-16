#!/bin/sh

func=$1

source ./helper.sh

args=$(json-search ${func}Request osc-api.json | json-search -K properties | tr -d "\n[],\"" | sed 's/  / /g')

for x in $args ;do
    snake_x=$(to_snakecase <<< $x)
    t=$(get_type $x)

    if [ $t == 'bool' ]; then
	cat <<EOF
	if (args->is_set_$snake_x) {
		osc_str_append_string(data, "\"$x\\":" );
                osc_str_append_bool(data, args->$snake_x);
	   	ret += 1;
	}
EOF
    elif [ $t ==  'int' ]; then
	cat <<EOF
	if (args->is_set_$snake_x) {
		osc_str_append_string(data, "\"$x\\":" );
                osc_str_append_int(data, args->$snake_x);
	   	ret += 1;
	}
EOF
    else
	cat <<EOF
	if (args->$snake_x) {
		osc_str_append_string(data, "\"$x\\":" );
                ret = !osc_str_append_string(data, args->$snake_x);
	}
EOF
    fi
done

