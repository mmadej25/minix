# brksize.s - Initial data break configuration
# Translated from ACK to AT&T syntax for i686-elf

.text
.section .rodata
.data
.bss

.global _brksize

.data
	.align 4
# The original file used '.data4 endbss' to store the address of the end of BSS.
# In GNU environmental conventions, '_end' represents the boundary of the BSS segment.
# This initializes '__brksize' with the physical address where the heap should start.
_brksize:
	.long _end
