.section .text.init, "ax", @progbits
.globl _start
.type _start, @function
_start:
  csrw mie, zero
  csrci mstatus, 8
  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop
  la sp, _stack_top
  la t0, __bss_start
  la t1, __bss_end
1:
  bgeu t0, t1, 2f
  sd zero, 0(t0)
  addi t0, t0, 8
  j 1b
2:
  call main
3:
  j 3b
.size _start, .-_start
