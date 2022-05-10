#include <stdlib.h>
#include <string.h>
#include "curl/curl.h"

#define AK_SIZE 20
#define SK_SIZE 40

struct osc_env {
	char *ak;
	char *sk;
	struct curl_slist *headers;
	CURL *c;
};

struct osc_resp {
	int len;
	char *buf;
};

struct osc_arg {
	____args____
};

/* Function that will write the data inside a variable */
static size_t write_data(void *data, size_t size, size_t nmemb, void *userp)
{
	size_t bufsize = size * nmemb;
	struct osc_resp *response = userp;
	int olen = response->len;

	response->len = response->len + bufsize;
	response->buf = realloc(response->buf, response->len);
	memcpy(response->buf + olen, data, bufsize);
	return bufsize;
}

void osc_init_resp(struct osc_resp *r)
{
	r->len = 0;
	r->buf = NULL;
}

void osc_deinit_resp(struct osc_resp *r)
{
	free(r->buf);
	osc_init_resp(r);
}

____func_code____

int osc_init_sdk(struct osc_env *e)
{
	char ak_sk[AK_SIZE + SK_SIZE + 2];

	e->ak = getenv("OSC_ACCESS_KEY");
	e->sk = getenv("OSC_SECRET_KEY");

	if (strlen(e->ak) != AK_SIZE || strlen(e->sk) != SK_SIZE) {
		fprintf(stderr, "Wrong size OSC_ACCESS_KEY or OSC_SECRET_KEY\n");
		return(1);
	}

	e->headers = NULL;
	stpcpy(stpcpy(stpcpy(ak_sk, e->ak), ":"), e->sk);
	e->c = curl_easy_init();
	e->headers = curl_slist_append(e->headers, "Content-Type: application/json");

	/* Setting HEADERS */
	curl_easy_setopt(e->c, CURLOPT_HTTPHEADER, e->headers);
	curl_easy_setopt(e->c, CURLOPT_WRITEFUNCTION, write_data);

	/* For authentification we specify the method and our acces key / secret key */
	curl_easy_setopt(e->c, CURLOPT_AWS_SIGV4, "osc");
	curl_easy_setopt(e->c, CURLOPT_USERPWD, ak_sk);

	return 0;
}

void osc_deinit_sdk(struct osc_env *e)
{
	curl_slist_free_all(e->headers);
	curl_easy_cleanup(e->c);
	e->c = NULL;
}
