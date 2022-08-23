#!/usr/bin/env bash

shopt -s expand_aliases

func=$1

source ./helper.sh

if [ "complex_struct" == "$2" ]; then
    args=$(jq .components.schemas.$func <<<  $OSC_API_JSON | json-search -K properties | tr -d '",[]')
    alias get_type=get_type2
else
    args=$(json-search ${func}Request osc-api.json | json-search -K properties | tr -d "\n[],\"" | sed 's/  / /g')
fi

for x in $args ;do
    snake_x=$(to_snakecase <<< $x)
    snake_x=$(sed s/default/default_arg/g <<< $snake_x)
    t=$(get_type $func $x)

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
    elif [ 'ref' == "$( echo $t | cut -d ' ' -f 1 )" ]; then
	type="$( echo $t | cut -d ' ' -f 2 | to_snakecase)"

	cat <<EOF
	if (args->${snake_x}_str) {
		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":" ))
			return -1;
                if (osc_str_append_string(data, args->${snake_x}_str))
			return -1;
		ret += 1;
	} else if (args->is_set_$snake_x) {
	       if (osc_str_append_string(data, "\"$x\": { " ))
			return -1;
	       if (${type}_setter(&args->${snake_x}, data) < 0)
	       	  	return -1;
	       if (osc_str_append_string(data, "}" ))
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

