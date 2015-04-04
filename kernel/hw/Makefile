
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)
CC = gcc
CFLAGS = -c -O2 -Wall -mrtd -I$(INCLUDEDIR)


OBJFILES = idt.o irq.o console.o io.o dma.o desc.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


idt.o: idt.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


irq.o: irq.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


console.o: console.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


desc.o: desc.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<



clean:
	rm -rf *.o
