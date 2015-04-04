

all:
	cd char; make all;
	cd video; make all;


drivers.img: all
	ld -r -o drivers.img ./char/*.o ./video/*.o


clean:
	cd char; make clean;
	cd video; make clean;
	rm -f drivers.img
