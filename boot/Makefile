
ASM = nasm
ASMFLAGS = -f bin

OBJFILES = bootsect.o setup.o system.o
INCLUDEFILES = config.h descriptor.h debug.h


all: $(OBJFILES)


bootsect.o: bootsect.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<

setup.o: setup.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<

system.o: system.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


image: all
	dd if=bootsect.o of=image bs=1b count=1
	dd if=setup.o of=image bs=1b seek=1 count=8
#	dd if=system.o of=image bs=1b seek=8 count=4
	sync

build_fd0: image
	@echo "insert a disk into the floppy drive /dev/fd0"
	@echo "press a key to continue"
	dd if=image of=/dev/fd0 bs=1b
	sync

clean:
	rm -f *.o
