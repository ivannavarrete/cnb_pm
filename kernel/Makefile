
INCLUDEDIR = ../include/

ASM = nasm
ASMFLAGS = -f elf -i$(INCLUDEDIR)


all:
	cd ./init; make all;
	cd ./hw; make all;
#	#cd ./mm; make all;
	cd ./sched; make all;
	cd ./lib; make all;


# It is absolutely necessary to have init/*.o first in the linking below
kernel.img: all
	ld -r -o kernel.img ./init/*.o ./hw/*.o ./sched/*.o ./lib/*.o
#	#ld -r -o kernel.img ./init/*.o ./hw/*.o ./mm/*.o ./sched/*.o ./lib/*.o


clean:
	cd ./hw; make clean;
	cd ./init; make clean;
	cd ./mm; make clean;
	cd ./sched; make clean;
	cd ./lib; make clean;
	rm -f kernel.img
