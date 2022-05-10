
osc_sdk.c: osc-api.json call_list arguments-list.json
	./mk_functions.sh call_list

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
	rm osc-api.json call_list osc_sdk.c arguments-list.json
