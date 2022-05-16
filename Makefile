# COGNAC for: Code Outscale Generator New Automatic Creator
# you can find a better name if you want.

main.c: osc-api.json call_list arguments-list.json osc_sdk.h osc_sdk.c
	./cognac_gen.sh main_tpl.c main.c

osc_sdk.c: osc-api.json call_list arguments-list.json osc_sdk.h
	./cognac_gen.sh lib.c osc_sdk.c

osc_sdk.h: osc-api.json call_list arguments-list.json
	./cognac_gen.sh lib.h osc_sdk.h

osc-api.json:
	curl -s https://raw.githubusercontent.com/outscale/osc-api/master/outscale.yaml \
		| yq > osc-api.json

arguments-list.json:
	json-search -s Request osc-api.json  | json-search -K properties \
	| sed 's/]/ /g' \
	| tr -d "\n[],\"" | sed -r 's/ +/ \n/g' \
	| sort | uniq | tr -d "\n" > arguments-list.json

call_list: osc-api.json
	json-search operationId osc-api.json | tr -d "\n[]\"" | sed 's/,/ /g' > call_list

clean:
	rm -vf osc-api.json call_list osc_sdk.c arguments-list.json osc_sdk.h main.c
