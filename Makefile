
MAKE = make


all:
	cd ./boot/;	$(MAKE) all;
	cd ./init/; $(MAKE) all;

image: all
	cd ./boot/; $(MAKE) image;
	mv ./boot/image ./
	dd if=./init/main.o of=image bs=1b seek=8
	

build_fd0: image
	@echo "insert a disk into the floppy drive /dev/fd0"
	@echo "press a key to continue"
	dd if=image of=/dev/fd0 bs=1b
	sync

clean:
	cd ./boot/; $(MAKE) clean;
	cd ./init/; $(MAKE) clean;
	rm -f image
