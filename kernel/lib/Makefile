
INCLUDEDIR = ../../include/


ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)
CC = gcc
CFLAGS = -c -O2 -fcall-saved-ebx -fcall-saved-ecx -fcall-saved-edx -fcall-saved-esi -fcall-saved-edi -Wall -mrtd -I$(INCLUDEDIR)

OBJFILES = printk.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


printk.o: printk.c
	$(CC) $(CFLAGS) -o $@ $<


clean:
	rm -rf *.o
