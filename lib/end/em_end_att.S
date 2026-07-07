#
.text
.align 4
.global _etext
.global etext
.global endtext
_etext:
etext:
endtext:
.section .rodata
.align 4
.global endrom
endrom:
.data
.align 4
.global _edata
.global edata
.global enddata
_edata:
edata:
enddata:
.bss
.align 4
# only for declaration of _end, __end or endbss.
.global _end
.global __end
.global endbss
_end:
__end:
endbss: