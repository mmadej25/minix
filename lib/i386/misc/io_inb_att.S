# ==============================================================================
# inb() - Input one byte (AT&T / GNU Assembler syntax for ELF)
# Author: Kees J. Bot (Converted to AT&T)
# unsigned char inb(unsigned short port);
# ==============================================================================

.text
.global inb
.type inb, @function

inb:
    pushl %ebp
    movl  %esp, %ebp
    movl  8(%ebp), %edx
    xorl  %eax, %eax
    inb   %dx, %al
    popl  %ebp
    ret
