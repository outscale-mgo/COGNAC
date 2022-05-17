# COGNAC for: Code Outscale Generator New Automatic Creator
# you can find a better name if you want.

include config.mk

all: cognac-completion.bash cognac

cognac: main.c osc_sdk.h osc_sdk.c
	gcc -Wall -Wextra main.c osc_sdk.c -lcurl -o cognac

main.c: osc-api.json call_list arguments-list.json config.sh
	./cognac_gen.sh main_tpl.c main.c c

osc_sdk.c: osc-api.json call_list arguments-list.json config.sh
	./cognac_gen.sh lib.c osc_sdk.c c

osc_sdk.h: osc-api.json call_list arguments-list.json config.sh
	./cognac_gen.sh lib.h osc_sdk.h c

cognac-completion.bash: osc-api.json call_list arguments-list.json config.sh
	./cognac_gen.sh cognac-completion-tpl.bash cognac-completion.bash bash

config.sh:
	echo "alias json-search=$(JSON_SEARCH)" > config.sh

osc-api.json:
	curl -s https://raw.githubusercontent.com/outscale/osc-api/master/outscale.yaml \
		| yq > osc-api.json

arguments-list.json: osc-api.json
	$(JSON_SEARCH) -s Request osc-api.json  | $(JSON_SEARCH) -K properties \
	| sed 's/]/ /g' \
	| tr -d "\n[],\"" | sed -r 's/ +/ \n/g' \
	| sort | uniq | tr -d "\n" > arguments-list.json

call_list: osc-api.json
	$(JSON_SEARCH) operationId osc-api.json | tr -d "\n[]\"" | sed 's/,/ /g' > call_list

clean:
	rm -vf osc-api.json call_list osc_sdk.c arguments-list.json osc_sdk.h main.c cognac config.sh cognac-completion.bash

.PHONY: clean

