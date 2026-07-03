# ==============================================================================
# outb() - Output one byte (AT&T / GNU Assembler syntax for ELF)
# Author: Kees J. Bot (Converted to AT&T)
# void outb(unsigned short port, unsigned char value);
# ==============================================================================

.text
.global outb
.type outb, @function

outb:
    pushl %ebp
    movl  %esp, %ebp
    movl  8(%ebp), %edx
    movl  12(%ebp), %eax
    outb  %al, %dx
    popl  %ebp
    ret
