
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -P/usr/include/nasm/nasm.h -i$(INCLUDEDIR)


OBJFILES = mm.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


mm.o: mm.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
