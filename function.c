static  int ____snake_func_____data(struct osc_____snake_func_____arg *args, struct osc_str *data)
{
	int ret = 0;
	int count_args = 0;

	if (!args)
		return 0;
	osc_str_append_string(data, "{");
	____construct_data____
	osc_str_append_string(data, "}");
	return !!ret;
}

int osc_____snake_func____(struct osc_env *e, struct osc_str *out, struct osc_____snake_func_____arg *args)
{
	CURLcode res = CURLE_OUT_OF_MEMORY;
	struct osc_str data;
	struct osc_str end_call;
	int r;

	osc_init_str(&data);
	osc_init_str(&end_call);
	r = ____snake_func_____data(args, &data);
	if (r < 0)
		goto out;

	osc_str_append_string(&end_call, e->endpoint.buf);
	osc_str_append_string(&end_call, "/api/v1/____func____");
	curl_easy_setopt(e->c, CURLOPT_URL, end_call.buf);
	curl_easy_setopt(e->c, CURLOPT_POSTFIELDS, r ? data.buf : "");
	curl_easy_setopt(e->c, CURLOPT_WRITEDATA, out);
	if (e->flag & OSC_VERBOSE_MODE) {
	  printf("<Date send to curl>\n%s\n</Date send to curl>\n", data.buf);
	}
	res = curl_easy_perform(e->c);
out:
	osc_deinit_str(&end_call);
	osc_deinit_str(&data);
	return res;
}
