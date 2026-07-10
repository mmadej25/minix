/* fs.ld - Linker script for MINIX servers (GNU ld syntax) */
OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS
{
    /* System servers in x86 architecture are safely positioned 
       starting from the 1MB boundary (0x00100000), similar to the kernel. */
    . = 0x00100000;

    /* Executable code segment (.text) */
    .text :
    {
        *(.text .text.*)
        *(.gnu.linkonce.t.*)
    }

    /* Align to a full page boundary (4KB) before the read-only data segment */
    . = ALIGN(0x1000);

    /* Read-only data segment (equivalent to the .rom section in ACK) */
    .rodata :
    {
        *(.rodata .rodata.*)
        *(.gnu.linkonce.r.*)
    }

    /* Align to a full page boundary (4KB) to protect memory segments */
    . = ALIGN(0x1000);

    /* Initialized data segment (.data) */
    .data :
    {
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
    }

    /* Align to a machine word (4 bytes) for the BSS segment */
    . = ALIGN(4);

    /* Uninitialized/zero-filled data segment (.bss) */
    .bss :
    {
        *(.bss .bss.*)
        *(COMMON)
    }

    /* Discard unnecessary compiler comments and note sections */
    /DISCARD/ :
    {
        *(.comment)
        *(.note.*)
    }
}