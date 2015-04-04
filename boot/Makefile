
INCLUDEDIR = ../include/

ASM = nasm
ASMFLAGS = -f bin -P/usr/include/nasm/nasm.h -i$(INCLUDEDIR)


OBJFILES = bootsect.o setup.o
INCLUDEFILES = $(INCLUDEDIR)*.h


all: $(OBJFILES)


bootsect.o: bootsect.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


setup.o: setup.asm $(INCLUDEFILES)
	$(ASM) $(ASMFLAGS) -o $@ $<


setup.img: all
	dd if=/dev/zero of=setup.img bs=1b count=16
	dd if=bootsect.o of=setup.img bs=1b count=1 conv=notrunc
	dd if=setup.o of=setup.img bs=1b seek=1 count=15 conv=notrunc
	sync

clean:
	rm -rf *\.o


