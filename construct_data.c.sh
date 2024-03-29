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
    elif [ "$t" ==  'string' ]; then
	cat <<EOF
	if (args->$snake_x) {
		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":\"" ))
			return -1;
                if (osc_str_append_string(data, args->$snake_x))
			return -1;
		if (osc_str_append_string(data, "\"" ))
			return -1;
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'int' -o  "$t" ==  'double' ]; then
	cat <<EOF
	if (args->is_set_$snake_x || args->$snake_x) {
		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":" ))
			return -1;
                if (osc_str_append_${t}(data, args->$snake_x))
			return -1;
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'array string' ]; then
	cat <<EOF
	if (args->$snake_x) {
		char **as;

		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":[" ))
			return -1;
		for (as = args->$snake_x; *as > 0; ++as) {
			if (as != args->$snake_x)
				if (osc_str_append_string(data, "," ))
					return -1;
			if (osc_str_append_string(data, "\"" ))
				return -1;
			if (osc_str_append_string(data, *as))
				return -1;
			if (osc_str_append_string(data, "\"" ))
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
    elif [ "$t" ==  'array integer' -o "$t" ==  'array double' ]; then
	if [ "$t" ==  'array integer' ]; then
	    sub_t='int'
	else
	    sub_t='double'
	fi

	cat <<EOF
	if (args->$snake_x) {
		$sub_t *ip;

		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":[" ))
			return -1;
		for (ip = args->$snake_x; *ip > 0; ++ip) {
			if (ip != args->$snake_x)
				if (osc_str_append_string(data, "," ))
					return -1;
			if (osc_str_append_${sub_t}(data, *ip))
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
	       if (count_args++ > 0)
		       if (osc_str_append_string(data, "," ))
			       return -1;
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
	suffix=""
	if [ 'ref' == $(echo $t | cut -d ' ' -f 2 ) ]; then
	    suffix="_str"
	    type="$( echo $t | cut -d ' ' -f 3 | to_snakecase)"


	    cat <<EOF
        if (args->$snake_x) {
	       	if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":[" ))
			return -1;
		for (int i = 0; i < args->nb_${snake_x}; ++i) {
	       	    struct ${type} *p = &args->$snake_x[i];
		    if (p != args->$snake_x)
		        if (osc_str_append_string(data, "," ))
			     return -1;
		    if (osc_str_append_string(data, "{ " ))
			return -1;
	       	    if (${type}_setter(p, data) < 0)
	       	  	return -1;
	       	    if (osc_str_append_string(data, "}" ))
			return -1;
		}
		if (osc_str_append_string(data, "]" ))
			return -1;
		ret += 1;
	} else
EOF
	fi
	cat <<EOF
	if (args->$snake_x${suffix}) {
		if (count_args++ > 0)
			if (osc_str_append_string(data, "," ))
				return -1;
		if (osc_str_append_string(data, "\"$x\\":" ))
			return -1;
                if (osc_str_append_string(data, args->${snake_x}${suffix}))
			return -1;
		ret += 1;
	}
EOF
    fi
done

