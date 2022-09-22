/**
 * BSD 3-Clause License
 *
 * Copyright (c) 2022, Outscale SAS
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

 /*
  * This code is autogenerated, don't edit it directely
  */

#ifndef __SDK_C__
#define __SDK_C__

#include <curl/curl.h>

struct osc_str {
	int len;
	char *buf;
};

#define OSC_ENV_FREE_AK_SK 1
#define OSC_ENV_FREE_REGION 2
#define OSC_VERBOSE_MODE 4
#define OSC_INSECURE_MODE 8

struct osc_env {
	char *ak;
	char *sk;
	char *region;
	int flag;
	struct curl_slist *headers;
	struct osc_str endpoint;
	CURL *c;
};

____args____

int osc_load_ak_sk_from_conf(const char *profile, char **ak, char **sk);
int osc_load_region_from_conf(const char *profile, char **region);

void osc_init_str(struct osc_str *r);
void osc_deinit_str(struct osc_str *r);
int osc_init_sdk(struct osc_env *e, const char *profile, unsigned int flag);
void osc_deinit_sdk(struct osc_env *e);
const char *osc_find_description(const char *call_name);

____functions_proto____

#endif /* __SDK_C__ */
