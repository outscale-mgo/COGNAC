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
    elif [ "ref" == $( echo "$t" | cut -d ' ' -f 1) ]; then
	echo "        char *${snake_name}_str;"
	t=$( echo $t | cut -f 2 -d ' ' )
	c_type="struct $(to_snakecase <<< $t) "
    fi
    echo "	${c_type}${snake_name}; // | $oref | $t | $snake_name "
}

for s in $COMPLEX_STRUCT; do
#for s in "skip"; do
    echo  "struct $(to_snakecase <<< $s) {"
    A_LST=$(jq .components.schemas.$s <<<  $OSC_API_JSON | json-search -K properties | tr -d '",[]')
    for a in $A_LST; do
	t=$(get_type2 "$s" "$a")
	snake_n=$(to_snakecase <<< $a)

	type_to_ctype "$t" "$snake_n"
    done
    echo -e '};\n'
done

for l in $CALL_LIST ;do
#for l in UpdateImage; do
    snake_l=$(to_snakecase <<< $l)
    ARGS_LIST=$(json-search -s  ${l}Request ./osc-api.json | json-search -KR "properties" | tr -d '"' | sed 's/,/\n/g')

    echo "struct osc_${snake_l}_arg  {"

    for x in $ARGS_LIST ;do
	snake_name=$(to_snakecase <<< "$x")

	#echo "get type: $func $x"
	t=$(get_type "$x" "$l")
	#echo "// TYPE: $t"
	type_to_ctype "$t" "${snake_name}"
    done
    echo -e "};\n"
done
