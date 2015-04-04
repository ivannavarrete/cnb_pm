
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)


OBJFILES = kbd.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


kbd.o: kbd.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
