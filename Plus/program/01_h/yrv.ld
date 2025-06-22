OUTPUT_ARCH( "riscv" )
ENTRY(_start)
MEMORY
{
  BRAM     (rx) : ORIGIN = 0x00000000, LENGTH = 16K
  BROM     (rx) : ORIGIN = 0x01000000, LENGTH = 16K

}

 SECTIONS
 {

  .text :
 {
    *(.text)
 }>BROM 

 .rodata :
 {  
    . = ALIGN(4);
    *(.rodata)
 }> BRAM

 .data :
 {  
    *(.data)
    . = ALIGN(4);
    _edata = .;
 }> BRAM


  
  /DISCARD/ :
  {
    *(.note.gnu.build-id)
    *(.riscv.attributes)
    *(.comment)
    *(.eh_frame)
  }
 

_end = .;
 }