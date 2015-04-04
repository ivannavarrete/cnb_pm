
all:
	cd ./boot; make all;
	cd ./kernel; make all;
	cd ./drivers; make all;


cnb.img: all
	cd ./boot; make setup.img;
	cd ./kernel; make kernel.img;
	cd ./drivers; make drivers.img;
	dd if=./boot/setup.img of=cnb.img bs=1b
	ld -Ttext 0 -Tdata 8000 -o system.img --entry kernel_init --oformat binary \
		./kernel/kernel.img ./drivers/drivers.img
	cat system.img >> cnb.img
	rm system.img
	sync


build_fd0: cnb.img
	dd if=cnb.img of=/dev/fd0 bs=1b
	sync


clean:
	cd ./boot; make clean;
	cd ./kernel; make clean;
	cd ./drivers; make clean;
	rm -f cnb.img;
