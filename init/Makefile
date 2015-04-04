
CC = gcc
CFLAGS = -s -Wall -O


OBJFILES = main.o


all: $(OBJFILES)

main.o: main.c
	$(CC) $(CCFLAGS) -c -o $@ $<

clean:
	rm -f *.o;
