
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)
CC = gcc
CFLAGS = -c -O2 -Wall -I$(INCLUDEDIR)


OBJFILES = irq.o io.o dma.o desc.o idt.o console.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


irq.o: irq.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


desc.o: desc.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


idt.o: idt.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


console.o: console.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
