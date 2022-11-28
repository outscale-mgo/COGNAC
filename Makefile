# COGNAC for: Code Outscale Generator New Automatic Creator
# you can find a better name if you want.

all: oapi-cli-completion.bash oapi-cli

config.mk:
	@echo "config.mk is not present"
	@echo "use './configure --help' for information, on how to make it"
	@exit 1

include config.mk

include oapi-cli.mk

main.c: osc-api.json call_list arguments-list.json config.sh main_tpl.c cognac_gen.sh mk_args.c.sh
	./cognac_gen.sh main_tpl.c main.c c

osc_sdk.c: osc-api.json call_list arguments-list.json config.sh lib.c cognac_gen.sh construct_data.c.sh mk_args.c.sh
	./cognac_gen.sh lib.c osc_sdk.c c

osc_sdk.h: osc-api.json call_list arguments-list.json config.sh lib.h cognac_gen.sh mk_args.c.sh
	./cognac_gen.sh lib.h osc_sdk.h c

oapi-cli-completion.bash: osc-api.json call_list arguments-list.json config.sh oapi-cli-completion-tpl.bash cognac_gen.sh
	./cognac_gen.sh oapi-cli-completion-tpl.bash oapi-cli-completion.bash bash

config.sh:
	echo "alias json-search=$(JSON_SEARCH)" > config.sh
	echo $(SED_ALIAS) >> config.sh

osc-api.json:
	curl -s https://raw.githubusercontent.com/outscale/osc-api/master/outscale.yaml \
		| yq $(YQ_ARG) > osc-api.json

arguments-list.json: osc-api.json
	$(JSON_SEARCH) -s Request osc-api.json  | $(JSON_SEARCH) -K properties \
	| sed 's/]/ /g' \
	| tr -d "\n[],\"" | sed -r 's/ +/ \n/g' \
	| sort | uniq | tr -d "\n" > arguments-list.json

call_list: osc-api.json
	$(JSON_SEARCH) operationId osc-api.json | tr -d "\n[]\"" | sed 's/,/ /g' > call_list

clean:
	rm -vf osc-api.json call_list osc_sdk.c arguments-list.json osc_sdk.h main.c oapi-cli config.sh oapi-cli-completion.bash

.PHONY: clean

