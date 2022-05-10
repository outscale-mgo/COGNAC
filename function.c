static char *____snake_func_____data(struct osc_arg *args)
{
	char *ret = NULL;
	char *tmp_ret = NULL;
	int tot_len = 0;

	if (!args)
		return NULL;
	____construct_data____
	return ret;
}

int osc_____snake_func____(struct osc_env *e, struct osc_resp *out, struct osc_arg *args)
{
	CURLcode res;
	char *data = ____snake_func_____data(args);

	curl_easy_setopt(e->c, CURLOPT_URL, "https://api.eu-west-2.outscale.com/api/v1/____func____");

	/* Empty post field to indicate we want to send a post request */
	curl_easy_setopt(e->c, CURLOPT_POSTFIELDS, data ? data : "");
	curl_easy_setopt(e->c, CURLOPT_WRITEDATA, out);
	res = curl_easy_perform(e->c);
	free(data);
	return res != CURLE_OK;
}
