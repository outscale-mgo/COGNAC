#include <string.h>
#include <stdio.h>
#include "osc_sdk.h"

int main(int ac, char **av)
{
	struct osc_env e;
	struct osc_resp r;

	osc_init_sdk(&e);
	osc_init_resp(&r);

	____cli_parser____

	osc_init_resp(&r);
	osc_init_sdk(&e);
}
