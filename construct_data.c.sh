#!/bin/sh

func=$1

source ./helper.sh

args=$(json-search ${func}Request osc-api.json | json-search -K properties | tr -d "\n[],\"" | sed 's/  / /g')

for x in $args ;do
    snake_x=$(to_snakecase <<< $x)
    cat << EOF
    	if (args->$snake_x) {
	        tot_len += strlen(args->$snake_x);
    	}

EOF
done

cat <<EOF
       if (tot_len < 1) {
               return NULL;
       }
       ret = malloc(tot_len + 1);
       if (!ret) { return NULL; }
       tmp_ret = ret;
EOF

for x in $args ;do
    snake_x=$(to_snakecase <<< $x)

    cat << EOF
    	if (args->$snake_x) {
	       tmp_ret = stpcpy(tmp_ret, args->$snake_x);
	       if (!tmp_ret) {
	               return NULL;
	       }
	}
EOF
done

