
#ifndef _DRIVER_H
#define _DRIVER_H


#define MAX_DRIVERS		0x20
#define MAX_MAJOR		0xFFFF

struct driver {
	int major;
	const char *name;
	int (*init)(void);
	int (*cleanup)(void);
	struct file_ops *fops;
	struct driver *next;
};


extern int register_driver(int major, const char *name, struct file_ops *fops);
extern int unregister_driver(int major, const char *name);


#endif
