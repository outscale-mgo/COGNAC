#!/bin/sh

ARGS_LIST=$(cat arguments-list.json)

for x in $ARGS_LIST ;do
    echo -n "        char *"
    echo -n $x | sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\L\2/g;s/[A-Z]/\L&/g;s/default/default_/'
    echo ';'
done
