# strcpy.S - Kopiowanie ciągu znaków
# Dostosowane do i686-elf-gcc (składnia AT&T, format ELF)

.global strcpy
.extern _strncpy        # Zakładamy, że wewnętrzny symbol __strncpy z ACK przyjmie postać _strncpy w ELF

.text
.align 16
strcpy:
    pushl   %ebp
    movl    %esp, %ebp
    pushl   %esi
    pushl   %edi
    
    movl    $-1, %ecx       # ecx = -1 (nieograniczona długość kopiowania)
    call    _strncpy        # Skok do wspólnego kodu realizującego strncpy
    
    movl    8(%ebp), %eax   # Zwróć wskaźnik docelowy s1 (zgodnie z sygnaturą char *strcpy)
    
    popl    %edi
    popl    %esi
    popl    %ebp
    ret