#!/usr/bin/env bash

OSC_API_JSON=$(cat ./osc-api.json)

CALL_LIST_FILE=./call_list
CALL_LIST=$(cat $CALL_LIST_FILE)

PIPED_CALL_LIST=$(sed 's/ / | /g' <<< $CALL_LIST)

lang=$3

shopt -s expand_aliases

source ./helper.sh

cli_c_type_parser()
{
    a=$1
    type=$2
    snake_a=$(to_snakecase <<< $a)
    snake_a=$(sed s/default/default_arg/g <<< $snake_a)

    if [ 'int' == "$type" ]; then
	cat <<EOF
				    TRY(!aa, "$a argument missing\n");
			            s->is_set_$snake_a = 1;
			     	    s->$snake_a = atoi(aa);
       			    } else
EOF
    elif [ 'bool' == "$type" ]; then
	cat <<EOF
			            s->is_set_$snake_a = 1;
				    if (!aa || !strcasecmp(aa, "true")) {
					s->$snake_a = 1;
				    } else if (!strcasecmp(aa, "false")) {
					s->$snake_a = 0;
				    } else {
					fprintf(stderr, "$a require true/false\n");
					return 1;
				    }
       			    } else
EOF
    elif [ 'array integer' == "$type" -o 'array string' == "$type" ]; then
	convertor=""
	if [ 'array integer' == "$type" ]; then
	    convertor=atoi
	fi
	cat <<EOF
				    TRY(!aa, "$a argument missing\n");
			            s->${snake_a}_str = aa;
			    } else if (!strcmp(str, "$a[]")) {
			      	    TRY(!aa, "$a[] argument missing\n");
				    SET_NEXT(s->${snake_a}, ${convertor}(aa), pa);
       			    } else
EOF
    elif [ 'ref' == $( echo "$type" | cut -d ' ' -f 1 ) ]; then

	sub_type=$(echo $type | cut -d ' ' -f 2 | to_snakecase)
	cat <<EOF
				    char *dot_pos;

				    TRY(!aa, "$a argument missing\n");
				    dot_pos = strchr(next_a, '.');
				    if (dot_pos++) {
					    ${sub_type}_parser(&s->${snake_a}, dot_pos, aa, pa);
					    s->is_set_${snake_a} = 1;
				    } else {
			                   s->${snake_a}_str = aa;
				    }
			    } else
EOF
    else
	cat <<EOF
				    TRY(!aa, "$a argument missing\n");
			            s->$snake_a = aa;
       			    } else
EOF
    fi

}

replace_args()
{
    while IFS= read -r line
    do
	#check ____args____ here
	grep ____args____ <<< "$line" > /dev/null
	have_args=$?
	grep ____func_code____ <<< "$line" > /dev/null
	have_func_code=$?
	grep ____functions_proto____ <<< "$line" > /dev/null
	have_func_protos=$?
	grep ____cli_parser____ <<< "$line" > /dev/null
	have_cli_parser=$?
	grep ____complex_struct_func_parser____ <<< "$line" > /dev/null
	have_complex_struct_func_parser=$?
	grep ____complex_struct_to_string_func____ <<< "$line" > /dev/null
	have_complex_struct_to_string_func=$?
	grep ____call_list_dec____ <<< "$line" > /dev/null
	have_call_list_dec=$?
	grep ____call_list_descriptions____ <<< "$line" > /dev/null
	have_call_list_des=$?

	if [ $have_args == 0 ]; then
	    ./mk_args.${lang}.sh
	elif [ $have_call_list_des == 0 ]; then
	    DELIMES=$(cut -d '(' -f 2 <<< $line | tr -d ')')
	    D1=$(cut -d ';' -f 1  <<< $DELIMES | tr -d "'")
	    D2=$(cut -d ';' -f 2  <<< $DELIMES | tr -d "'")
	    D3=$(cut -d ';' -f 3  <<< $DELIMES | tr -d "'")
	    for x in $CALL_LIST ;do
		echo -en $D1
		echo $OSC_API_JSON | jq .paths.\""/$x"\".description | sed 's/<br \/>//g'
		echo -en $D2
	    done
	    echo -ne $D3
	elif [ $have_call_list_dec == 0 ]; then
	    DELIMES=$(cut -d '(' -f 2 <<< $line | tr -d ')')
	    D1=$(cut -d ';' -f 1  <<< $DELIMES | tr -d "'")
	    D2=$(cut -d ';' -f 2  <<< $DELIMES | tr -d "'")
	    D3=$(cut -d ';' -f 3  <<< $DELIMES | tr -d "'")
	    for x in $CALL_LIST ;do
		echo -en $D1
		echo -n $x
		echo -en $D2
	    done
	    echo -ne $D3
	elif [ $have_complex_struct_to_string_func == 0 ]; then
	    COMPLEX_STRUCT=$(jq .components <<< $OSC_API_JSON | json-search -KR schemas | tr -d '"' | sed 's/,/\n/g' | grep -v Response | grep -v Request)

	    for s in $COMPLEX_STRUCT; do
		struct_name=$(to_snakecase <<< $s)
		cat <<EOF
static int ${struct_name}_setter(struct ${struct_name} *args, struct osc_str *data) {
       int count_args = 0;
       int ret = 0;
EOF
		A_LST=$(jq .components.schemas.$s <<<  $OSC_API_JSON | json-search -K properties | tr -d '",[]')

		./construct_data.c.sh $s complex_struct
		cat <<EOF
	return !!ret;
}
EOF
	    done
	elif [ $have_complex_struct_func_parser == 0 ]; then
	    COMPLEX_STRUCT=$(jq .components <<< $OSC_API_JSON | json-search -KR schemas | tr -d '"' | sed 's/,/\n/g' | grep -v Response | grep -v Request)

	    for s in $COMPLEX_STRUCT; do
		#for s in "skip"; do
		struct_name=$(to_snakecase <<< $s)

		echo  "int ${struct_name}_parser(struct $struct_name *s, char *str, char *aa, struct ptr_array *pa) {"
		A_LST=$(jq .components.schemas.$s <<<  $OSC_API_JSON | json-search -K properties | tr -d '",[]')
		for a in $A_LST; do
		    t=$(get_type2 "$s" "$a")
		    snake_n=$(to_snakecase <<< $a)

		    echo "	if (!strcmp(str, \"$a\")) {"
		    cli_c_type_parser "$a" "$t"
		done
		cat <<EOF
	{
		fprintf(stderr, "'%s' not an argumemt of '$s'\n", str);
	}
EOF
		echo "	      return 0;"
		echo -e '}\n'
	    done

	elif [ $have_cli_parser == 0 ] ; then
	    for l in $CALL_LIST; do
		snake_l=$(to_snakecase <<< $l)
		arg_list=$(json-search ${l}Request osc-api.json \
			       | json-search -K properties \
			       | tr -d "[]\"," | sed '/^$/d')

		cat <<EOF
              if (!strcmp("$l", av[i])) {
		     json_object *jobj;
		     struct ptr_array opa = {0};
		     struct ptr_array *pa = &opa;
	      	     struct osc_${snake_l}_arg a = {0};
		     struct osc_${snake_l}_arg *s = &a;
	             int cret;
		     ${snake_l}_arg:

		     if (i + 1 < ac && av[i + 1][0] == '-' && av[i + 1][1] == '-') {
 		             char *next_a = &av[i + 1][2];
			     char *str = next_a;
 		     	     char *aa = i + 2 < ac ? av[i + 2] : 0;
			     int incr = aa ? 2 : 1;

			     if (aa && aa[0] == '-' && aa[1] == '-') {
				aa = 0;
				incr = 1;
			     }
EOF

		for a in $arg_list ; do
		    type=$(get_type $l $a)
		    snake_a=$(to_snakecase <<< $a)

		    cat <<EOF
			      if (!argcmp(next_a, "$a") ) {
EOF
		    cli_c_type_parser "$a" "$type"
		done

		cat <<EOF
			    {
				fprintf(stderr, "'%s' is not a valide argument for '$l'\n", next_a);
				return 1;
			    }
		            i += incr;
			    goto ${snake_l}_arg;
		     }
		     cret = osc_$snake_l(&e, &r, &a);
            	     TRY(cret, "fail to call $l: %s\n", curl_easy_strerror(cret));
		     if (program_flag & OAPI_RAW_OUTPUT)
		             puts(r.buf);
		     else {
			     jobj = json_tokener_parse(r.buf);
			     puts(json_object_to_json_string_ext(jobj,
					JSON_C_TO_STRING_PRETTY | JSON_C_TO_STRING_NOSLASHESCAPE |
					color_flag));
			     json_object_put(jobj);
		      }
		     osc_deinit_str(&r);
	      } else
EOF
	    done
	elif [ $have_func_protos == 0 ] ; then
	    for l in $CALL_LIST; do
		snake_l=$(to_snakecase <<< $l)
		echo "int osc_${snake_l}(struct osc_env *e, struct osc_str *out, struct osc_${snake_l}_arg *args);"
	    done
	elif [ $have_func_code == 0 ]; then
	    for x in $CALL_LIST ;do
		snake_x=$(to_snakecase <<< $x)
		dashed_args=$(json-search ${x}Request <<< $OSC_API_JSON \
				  | json-search -K properties  | tr -d "[]\"," \
				  | sed '/^$/d;s/  / --/g' | tr -d "\n")

		while IFS= read -r fline
		do
		    grep ____construct_data____ <<< "$fline" > /dev/null
		    have_construct_data=$?
		    if [ $have_construct_data == 0 ]; then
			./construct_data.${lang}.sh $x
		    else
			sed "s/____func____/$x/g; s/____snake_func____/$snake_x/g;s/____dashed_args____/$dashed_args/g" <<< "$fline"
		    fi
		done < function.${lang}
	    done
	else
	    sed "s/____call_list____/${CALL_LIST}/g;s/____piped_call_list____/${PIPED_CALL_LIST}/" <<< "$line";
	fi
    done < $1
}

replace_args $1 > $2
