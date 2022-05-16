#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "osc_sdk.h"

int main(int ac, char **av)
{
	struct osc_env e;
	struct osc_str r;

	osc_init_sdk(&e);
	osc_init_str(&r);

	____cli_parser____

	osc_init_str(&r);
	osc_init_sdk(&e);
}
