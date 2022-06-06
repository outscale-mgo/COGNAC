#!/usr/bin/env bash

OSC_API_JSON=$(cat ./osc-api.json)

CALL_LIST_FILE=./call_list
CALL_LIST=$(cat $CALL_LIST_FILE)

PIPED_CALL_LIST=$(sed 's/ / | /g' <<< $CALL_LIST)

lang=$3

shopt -s expand_aliases

source ./helper.sh

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

	if [ $have_args == 0 ]; then
	    ./mk_args.${lang}.sh
	elif [ $have_cli_parser == 0 ] ; then
	    for l in $CALL_LIST; do
		snake_l=$(to_snakecase <<< $l)
		arg_list=$(json-search ${l}Request osc-api.json \
			       | json-search -K properties \
			       | tr -d "[]\"," | sed '/^$/d')

		cat <<EOF
              if (!strcmp("$l", av[i])) {
	      	     struct osc_${snake_l}_arg a = {0};
		     ${snake_l}_arg:
		     if (i + 1 < ac && av[i + 1][0] == '-' && av[i + 1][1] == '-') {
 		             char *next_a = &av[i + 1][2];
 		     	     char *aa = i + 2 < ac ? av[i + 2] : 0;
			     int incr = aa ? 2 : 1;

			     if (aa && aa[0] == '-' && aa[1] == '-') {
				aa = 0;
				incr = 1;
			     }
EOF

		for a in $arg_list ; do
		    type=$(get_type $a $l)
		    snake_a=$(to_snakecase <<< $a)

		    cat <<EOF
			      if (!strcmp(next_a, "$a") ) {
EOF
		    if [ 'int' == "$type" ]; then
			cat <<EOF
				    if (!aa) {
					fprintf(stderr, "$a argument missing\n");
					return 1;
				    }
			            a.is_set_$snake_a = 1;
			     	    a.$snake_a = atoi(aa);
       			    } else
EOF
		    elif [ 'bool' == "$type" ]; then
			cat <<EOF
			            a.is_set_$snake_a = 1;
				    if (!aa || !strcasecmp(aa, "true")) {
					a.$snake_a = 1;
				    } else if (!strcasecmp(aa, "false")) {
					a.$snake_a = 0;
				    } else {
					fprintf(stderr, "$a require true/false\n");
					return 1;
				    }
       			    } else
EOF
		    elif [ 'array integer' == "$type" ]; then
		    cat <<EOF
				    if (!aa) {
					fprintf(stderr, "$a argument missing\n");
					return 1;
				    }
			            a.${snake_a}_str = aa;
       			    } else
EOF
		    else
		    cat <<EOF
				    if (!aa) {
					fprintf(stderr, "$a argument missing\n");
					return 1;
				    }
			            a.$snake_a = aa;
       			    } else
EOF
		    fi
		done

		cat <<EOF
			    {
				fprintf(stderr, "'%s' is not a valide argument for '$l'\n", next_a);
				return 1;
			    }
		            i += incr;
			    goto ${snake_l}_arg;
		     }
            	     TRY(osc_$snake_l(&e, &r, &a), "fail to call $l");
		     puts(r.buf);
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
