
INCLUDEDIR = ../../include/

ASM = nasm
ASMFLAGS = -f elf -P/usr/include/nasm/nasm.h -i$(INCLUDEDIR)

OBJFILES = idt.o gdt.o irq.o descriptor.o ll.o console.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


gdt.o: gdt.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


idt.o: idt.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


irq.o: irq.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


descriptor.o: descriptor.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


ll.o: ll.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


console.o: console.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


clean:
	rm -rf *.o
