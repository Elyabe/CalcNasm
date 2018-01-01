export CC = gcc
CC = gcc
CFLAGS = -no-pie


NASM_FLAGS=-f elf64

all: mk comp exec

mk:
	nasm $(NASM_FLAGS) trabalho.asm

comp: trabalho.o
	$(CC) $(CFLAGS) -o exe trabalho.o

exec:
	./exe
	

.PHONY: clean

clean: 
	rm -f *.o trabalho
	rm -f *.so