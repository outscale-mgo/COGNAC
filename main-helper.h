#ifndef MAIN_HELPER_H_
#define MAIN_HELPER_H_

//SET_NEXT(s->tag_values, aa, to_free_l, to_free);


struct ptr_array {
	void **ptrs;
	int l;
	int size;
};

#define SET_NEXT(a, v, pa)						\
	do {								\
		int cnt;						\
		if (!a) {						\
			ptr_array_append(pa, a);			\
			a = calloc(64, sizeof(v));			\
		}							\
		for (cnt = 0; a[cnt]; ++cnt);				\
		if (cnt && (cnt % 63) == 0) {				\
			a = realloc(a, (cnt + 1 + 64) * sizeof(v));	\
			memset(a + cnt + 1, 0, 64 * sizeof(v));		\
		}							\
		a[cnt] = v;						\
} while (0)

static inline int ptr_array_append(struct ptr_array *pa, void *ptr)
{
	if (!(pa->l & 63)) { /* need grow up */
		pa->size += 64;
		pa->ptrs = realloc(pa->ptrs, pa->size);
		if (!pa->ptrs)
			return -1;
	}
	pa->ptrs[pa->l++] = ptr;
	return 0;
}

static inline int ptr_array_free_all(struct ptr_array *pa)
{
	if (pa->ptrs) {
		for (int i = 0; i < pa->l; ++i) {
			free(pa->ptrs[i]);
		}
		free(pa->ptrs);
		pa->ptrs = NULL;
		pa->size = 0;
		pa->l = 0;
	}
}


#endif /* MAIN_HELPER_H_ */
