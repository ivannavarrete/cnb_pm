
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)


OBJFILES = init.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


init.o: init.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
