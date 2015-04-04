
#ifndef _IO_H
#define _IO_H


extern int request_io(int start, int end, const char *dev_name);
extern int release_io(int start, int end);
extern int check_io(int start, int end);
struct io_region *find_gap(struct io_region *root, int start, int end);


#define MAX_IO_PORT		0xFFFF
#define MAX_IO_REGIONS	127

struct io_region {
	char lock;
	int start;
	int end;
	const char *dev_name;
	struct io_region *next;
};


#endif
