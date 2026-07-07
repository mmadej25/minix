# strlen.S - Zwracanie długości ciągu znaków (wersja zoptymalizowana x86)
# Dostosowane do i686-elf-gcc (składnia AT&T, format ELF)

.global strlen
.extern _strnlen        # Zakładamy, że wewnętrzny symbol _strnlen / __strnlen też będzie linkowany

.text
.align 16
strlen:
    movl    $-1, %ecx   # ecx = -1 (oznacza nieograniczoną długość szukania)
    jmp     _strnlen    # Skok do wspólnego kodu realizującego strnlen