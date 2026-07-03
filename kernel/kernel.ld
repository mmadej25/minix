/* ==============================================================================
 * src/kernel/kernel.ld
 * Linker script for the MINIX kernel (i686 ELF)
 * ============================================================================== */

ENTRY(MINIX) /* Entry point defined as the global 'MINIX' label in mpx386_att.S */

SECTIONS
{
    /* Load the kernel starting at the 1MB physical address boundary */
    . = 0x00100000;

    /* Text section: Executable CPU instructions */
    .text : AT(ADDR(.text)) {
        *(.text .text.*)
        . = ALIGN(4096);
        etext = .; /* Define 'etext' at the end of the text section */
        _etext = .;
    }

    /* Rodata section: Read-only data like constants and string literals */
    .rodata : AT(ADDR(.rodata)) {
        *(.rodata .rodata.*)
        . = ALIGN(4096);
    }

    /* Data section: Initialized global and static variables */
    .data : AT(ADDR(.data)) {
        *(.data .data.*)
        . = ALIGN(4096);
    }

    /* Bss section: Uninitialized data, zero-filled automatically at boot */
    .bss : AT(ADDR(.bss)) {
        *(.COMMON)
        *(.bss .bss.*)
        . = ALIGN(4096);
        end = .; /* Define 'end' at the end of the bss section */
        _end = .;
    }

    /* Discard unnecessary toolchain-specific metadata sections */
    /DISCARD/ : {
        *(.comment)
        *(.note .note.*)
    }
}
