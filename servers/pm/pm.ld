/* pm.lds - Linker script for the Process Manager in ELF format */

OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)

/* Entry point of the application (typically defined in crt0.S or head.S from the rts library) */
ENTRY(_start)

SECTIONS
{
    /* MINIX user-space servers typically start at logical address 0x0 */
    . = 0x0;

    /* Text section (code and read-only data) */
    .text : {
        *(.text .text.*)
        *(.rodata .rodata.*)
        . = ALIGN(4096); /* Align to page boundary */
    }

    /* Initialized data section */
    .data : {
        *(.data .data.*)
        . = ALIGN(4096);
    }

    /* Uninitialized data section (cleared to zeroes at startup) */
    .bss : {
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4096);
    }

    /* Discard unused metadata and compiler comment sections to keep the binary clean */
    /DISCARD/ : {
        *(.comment)
        *(.note .note.*)
    }
}
