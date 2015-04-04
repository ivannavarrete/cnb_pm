
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)


OBJFILES = printk.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


printk.o: printk.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
