#!/usr/bin/env bash

shopt -s expand_aliases

func=$1

source ./helper.sh

args=$(json-search ${func}Request osc-api.json | json-search -K properties | tr -d "\n[],\"" | sed 's/  / /g')

for x in $args ;do
    snake_x=$(to_snakecase <<< $x)
    t=$(get_type $x $func)

    if [ "$t" == 'bool' ]; then
	cat <<EOF
	if (args->is_set_$snake_x) {
		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":" ))
			return -1;
                if (osc_str_append_bool(data, args->$snake_x))
			return -1;
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'int' ]; then
	cat <<EOF
	if (args->is_set_$snake_x) {
		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":" ))
			return -1;
                if (osc_str_append_int(data, args->$snake_x))
			return -1;
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'array integer' ]; then
	cat <<EOF
	if (args->$snake_x) {
		int *ip;

		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":[" ))
			return -1;
		for (ip = args->$snake_x; *ip > 0; ++ip) {
			if (ip != args->$snake_x)
				if (osc_str_append_string(data, "," ))
					return -1;
			if (osc_str_append_int(data, *args->$snake_x))
				return -1;
		}
		if (osc_str_append_string(data, "]" ))
			return -1;
		ret += 1;
	} else if (args->${snake_x}_str) {
		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":" ))
			return -1;
                if (osc_str_append_string(data, args->${snake_x}_str))
			return -1;
		ret += 1;
	}
EOF
    else
	cat <<EOF
	if (args->$snake_x) {
		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":" ))
			return -1;
                if (osc_str_append_string(data, args->$snake_x))
			return -1;
		ret += 1;
	}
EOF
    fi
done

