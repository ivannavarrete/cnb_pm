
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)


OBJFILES = mm.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


mm.o: mm.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
