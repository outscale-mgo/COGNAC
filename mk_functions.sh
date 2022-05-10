#!/bin/sh

CALL_LIST_FILE=$1
CALL_LIST=$(cat $1)

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
	if [ $have_args == 0 ]; then
	    ./mk_args.c.sh
	elif [ $have_func_code == 0 ]; then
	    for x in $CALL_LIST ;do
		snake_x=$(to_snakecase <<< $x)

		while IFS= read -r fline
		do
		    grep ____construct_data____ <<< "$fline" > /dev/null
		    have_construct_data=$?
		    if [ $have_construct_data == 0 ]; then
			./construct_data.c.sh $x
		    else
			sed "s/____func____/$x/g; s/____snake_func____/$snake_x/g" <<< "$fline"
		    fi
		done < function.c
	    done
	else
	    echo "$line";
	fi
    done < $1
}

replace_args lib.c > osc_sdk.c
