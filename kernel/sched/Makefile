
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)


OBJFILES = sched.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


sched.o: sched.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
