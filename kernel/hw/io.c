
/*
 * IO-port region management.
 */

#include <kernel.h>
#include <io.h>
#include <errno.h>


struct io_region io_list = {
	1,
	0,
	0,
	"",
	0
};

struct io_region io_table[MAX_IO_REGIONS];


int request_io(int start, int end, const char *name) {
	struct io_region *i1;
	int i;

	/* find a free entry in table */
	for (i=0; i<MAX_IO_REGIONS; i++)
		if (io_table[i].lock == 0)
			break;
	if (i == MAX_IO_REGIONS) {
		Printk("kernel can't accept more io regions\n");
		return -ENOMEM;
	}

	/* find an entry in list */
	i1 = find_gap(&io_list, start, end);
	if (i1 == NULL)
		return -EBUSY;

	/* link io region into list */
	io_table[i].lock = 1;
	io_table[i].start = start;
	io_table[i].end = end;
	io_table[i].dev_name = name;
	io_table[i].next = i1->next;
	i1->next = &io_table[i];

	return 0;
}


int release_io(int start, int end) {
	struct io_region *i1, *i2;
	
	i1 = &io_list;
	i2 = i1->next;
	do {
		if (i2->start == start && i2->end == end)
			break;
		if (i2 == NULL)
			return -ENODEV;
		i1 = i1->next;
		i2 = i1->next;
	} while (1);

	/* free region */
	i1->next = i2->next;
	i2->lock = 0;

	return 0;
}


/* check if io region is free */
int check_io(int start, int end) {
	if (find_gap(&io_list, start, end))
		return 0;
	else
		return 1;
}


struct io_region *find_gap(struct io_region *root, int start, int end) {
	struct io_region *i1, *i2;

	i1 = root;
	i2 = root->next;

	while (i2 != NULL) {
		if (i1 == root) {
			if (i1->end <= start && i2->start > end)
				break;
		} else {
			if (i1->end < start && i2->start > end)
				break;
		}

		if (i1->end >= start || i2->start <= end)
			return NULL;
		i1 = i1->next;
		i2 = i1->next;
	}
	return i1;
}
