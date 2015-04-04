/*
 * 24/04/2000
 */

#include <kernel.h>
#include <driver.h>
#include <errno.h>


/* root driver */
struct driver driver_list = {
	0,
	0,
	0,
	NULL,
	NULL,
	NULL
};

/* table of driver structures */
struct driver driver_table[MAX_DRIVERS];


int register_driver(int major, const char *name, struct file_ops *fops) {
	struct driver *d1, *d2;
	int i;

	/* major sanity check */
	if (major == 0 || major > MAX_MAJOR)
		return -EINVAL;

	/* find an entry for new driver in table */
	for (i=0; i<MAX_DRIVERS; i++) {
		if (driver_table[i].major == 0)
			break;
	}
	if (i == MAX_DRIVERS) {
		printk("kernel can't accept more drivers\n");
		return -ENOMEM;
	}

	/* link driver into driver list */
	for (d1 = &driver_list, d2 = d1->next; ; d1 = d2, d2 = d2->next) {
		if (d2 == NULL)
			break;
		else if (d1->major < major && d2->major > major)
			break;
	}
	driver_table[i].major = major;
	driver_table[i].name = name;
	driver_table[i].fops = fops;
	driver_table[i].next = d1->next;
	d1->next = &driver_table[i];

	return 0;
}


int unregister_driver(int major, const char *name) {
	struct driver *d1, *d2;

	/* major sanity check */
	if (major == 0 || major > MAX_MAJOR)
		return -EINVAL;
	
	/* find driver in driver list  and remove it */
	for (d1 = &driver_list, d2 = d1->next; ; d1 = d2, d2 = d2->next) {
		if (d2 == NULL)
			return -EINVAL;
		
		if (d2->major == major && strcmp(d2->name, name)) {
			d2->major = 0;
			d1->next = d2->next;
			return 0;
		}
	}
}
