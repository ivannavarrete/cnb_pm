
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -P/usr/include/nasm/nasm.h -i$(INCLUDEDIR)

OBJFILES = sched.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


sched.o: sched.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


#task.o: task.asm $(INCLUDEFILES)
#	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -rf *.o
