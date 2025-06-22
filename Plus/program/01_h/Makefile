LD=/c/riscv/bin/riscv-none-elf-gcc 
AS=/c/riscv/bin/riscv-none-elf-as
OBJ = /c/riscv/bin/riscv-none-elf-objcopy

LDFLAGS=  -nostdlib -Tyrv.ld  -nostartfiles -nostdlib


B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)


all:main.mem16

main.o:main.S
	$(AS) $< -o $@ 


main.elf:main.o  
	$(LD) $(LDFLAGS)  -o $@ $^  


main.bin:main.elf
	$(OBJ) -O binary main.elf main.bin

main.mem16: main.bin
	../common/bin2hex -w16  main.bin > main.mem16
  


clean:
	rm main.o

