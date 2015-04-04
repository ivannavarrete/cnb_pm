
INCLUDEDIR = ../../include/


ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)
CC = gcc
CFLAGS = -c -O2 -Wall -mrtd -I$(INCLUDEDIR)

OBJFILES = printk.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


#printk.o: printk.asm $(INCLUDEFILES)
#	$(ASM) $(ASMFLAGS) -o $@ $<


printk.o: printk.c
	$(CC) $(CFLAGS) -o $@ $<


clean:
	rm -f *.o
