#!/usr/bin/env bash

shopt -s expand_aliases

source "./helper.sh"

CALL_LIST_FILE=./call_list
CALL_LIST=$(cat $CALL_LIST_FILE)

COMPLEX_STRUCT=$(jq .components <<< $OSC_API_JSON | json-search -KR schemas | tr -d '"' | sed 's/,/\n/g' | grep -v Response | grep -v Request)

type_to_ctype() {
    t="$1"
    snake_name="$2"
    c_type="char *"
    oref="$t"

    if [ "$t" == 'int' -o "$t" == 'bool' ]; then
	snake_name=$(sed s/default/default_arg/g <<< $snake_name)
	echo "        int is_set_${snake_name};"
	c_type="int "
    elif [ "$t" == 'array integer' ]; then
	echo "        char *${snake_name}_str;"
	c_type="int *"
    elif [ "$t" == 'array string' ]; then
	echo "        char *${snake_name}_str;"
	c_type="char **"
    elif [ "ref" == $( echo "$t" | cut -d ' ' -f 1) ]; then
	echo "        char *${snake_name}_str;"
	echo "        int is_set_${snake_name};"
	t=$( echo $t | cut -f 2 -d ' ' )
	c_type="struct $(to_snakecase <<< $t) "
    elif [ "array" == $( echo "$t" | cut -d ' ' -f 1) ]; then
	if [ "ref" == $( echo "$t" | cut -d ' ' -f 2) ]; then
	    t=$( echo $t | cut -f 3 -d ' ' )
	    echo "        char *${snake_name}_str;"
	    echo "        int nb_${snake_name};"
	    c_type="struct $(to_snakecase <<< $t) *"
	fi
    fi
    echo "	${c_type}${snake_name}; /* $oref */"
}

for s in $COMPLEX_STRUCT; do
#for s in "skip"; do
    echo  "struct $(to_snakecase <<< $s) {"
    st_info=$(jq .components.schemas.$s <<<  $OSC_API_JSON)
    A_LST=$(json-search -K properties <<< $st_info | tr -d '",[]')
    for a in $A_LST; do
	t=$(get_type3 "$st_info" "$a")
	snake_n=$(to_snakecase <<< $a)
	echo '        /*'
	get_type_description "$st_info" "$a" | tr -d '"' | fold -s -w70 | sed -e  's/^/         * /g'
	echo '         */'

	type_to_ctype "$t" "$snake_n"
    done
    echo -e '};\n'
done

for l in $CALL_LIST ;do
#for l in UpdateImage; do
    snake_l=$(to_snakecase <<< $l)
    request=$(json-search -s  ${l}Request ./osc-api.json)
    ARGS_LIST=$(echo $request | json-search -KR "properties" | tr -d '"' | sed 's/,/\n/g')

    echo "struct osc_${snake_l}_arg  {"
    echo -n "        /* Required:"
    echo $request | json-search required 2>&1 | tr -d "[]\"\n" | tr -s ' ' | sed 's/nothing found/none/g' | to_snakecase
    echo " */"

    for x in $ARGS_LIST ;do
	snake_name=$(to_snakecase <<< "$x")

	t=$(get_type "$l" "$x")
	#echo "get type: $func $x"
	echo '        /*'
	get_type_description "$request" "$x" | tr -d '"' | fold -s -w70 | sed -e  's/^/         * /g' | sed "s/null/See '$snake_name' type documentation/"
	echo '         */'
	#echo "/* TYPE: $t */"
	type_to_ctype "$t" "${snake_name}"
    done
    echo -e "};\n"
done
