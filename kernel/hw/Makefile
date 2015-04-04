
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)


OBJFILES = irq.o io.o dma.o desc.o idt.o console.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


irq.o: irq.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


io.o: io.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


dma.o: dma.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


desc.o: desc.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


idt.o: idt.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


console.o: console.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -f *.o
