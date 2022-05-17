#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "osc_sdk.h"

#define TRY(f) do {				\
  if (f) {return 1;}				\
  } while(0)

int main(int ac, char **av)
{
	struct osc_env e;
	struct osc_str r;
	int i;

	TRY(osc_init_sdk(&e));
	osc_init_str(&r);
	
	if (ac < 2) {
		printf("Usage: %s CallName [--Params ParamArgument]\n", av[0]);
		return 0;
	}

	for (i = 1; i < ac; ++i) {
		____cli_parser____
		{
			printf("Unknow Call %s\n", av[i]);
		}
	}
	
	osc_init_str(&r);
	osc_init_sdk(&e);
	return 0;
}
