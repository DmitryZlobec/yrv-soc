.global  _start

        .equ  membase, 0x00000     # i/o at 0xffff0000
        .equ  iobase, 0xffff0     # i/o at 0xffff0000

.org    0x200
_start:
	lui  a3,0x00450
	lui a4,membase
        sw  a3,0(a4)	
	
	
        li  a3,'H'
	lui a4,iobase
        sb  a3,0(a4)

	lui a4,membase
        lb  a2,2(a4)
	lui a4,iobase
        sb  a2,0(a4)
	
        li  a3,'L'
	lui a4,iobase
        sb  a3,0(a4)

	li  a3,'O'
	lui a4,iobase
        sb  a3,0(a4)
	wfi
