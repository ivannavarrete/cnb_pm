
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)


OBJFILES = vga.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


vga.o: vga.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
