
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)


OBJFILES = drivers.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


drivers.o: drivers.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
