OUTPUT_ARCH(riscv)
ENTRY(_start)
/* __ddr_base comes from the canonical SoC map. This reserves 16 KiB for
 * software's stack; it does not specify or assume a physical DDR capacity. */
SECTIONS
{
  . = __ddr_base;
  .text : { KEEP(*(.text.init)) *(.text .text.*) }
  .rodata : { *(.rodata .rodata.* .srodata .srodata.*) }
  .data : {
    __global_pointer$ = . + 0x800;
    *(.data .data.* .sdata .sdata.*)
  }
  . = ALIGN(8);
  __bss_start = .;
  .bss (NOLOAD) : { *(.bss .bss.* .sbss .sbss.*) *(COMMON) }
  . = ALIGN(8);
  __bss_end = .;
  .stack (NOLOAD) : { . = . + 0x4000; }
  . = ALIGN(16);
  _stack_top = .;
  __app_ram_end = .;
}
