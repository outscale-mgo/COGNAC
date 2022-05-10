#include "osc_sdk.h"

int main(int ac, char **av)
{
	struct osc_env e;
	struct osc_resp r;

	osc_init_sdk(&e);
	osc_init_resp(&r);

	osc_read_load_balancers(&e, &r, NULL);
	printf("[%s", r.buf);
	osc_deinit_resp(&r);

	osc_read_images(&e, &r, &(struct osc_arg){.filters="{\"Filters\": { \"AccountAliases\": [\"Outscale\"]}}"});
	printf(",\n%s]\n", r.buf);

	osc_init_resp(&r);
	osc_init_sdk(&e);
}
