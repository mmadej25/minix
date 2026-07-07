# _strnlen.S - Wewnętrzna funkcja wyznaczania długości ciągu z limitem znaków
# Dostosowane do i686-elf-gcc (składnia AT&T, format ELF)

.global _strnlen

.text
.align 16
_strnlen:
    pushl   %ebp
    movl    %esp, %ebp
    pushl   %edi
    
    movl    8(%ebp), %edi       # edi = wskaźnik na string
    xorb    %al, %al            # al = 0 (szukamy bajtu zerowego '\0')
    movl    %ecx, %edx          # Zapisz maksymalny licznik z ecx do edx
    
    cmpb    $1, %cl             # Flaga 'Z' musi być czyszczona, jeśli ecx == 0
    cld                         # Przeszukanie w przód
    repne   scasb               # Szukaj znaku NULL w ciągu
    
    jne     no0                 # Jeśli nie znaleziono zera, skocz do no0
    incl    %ecx                # Znaleziono zero, nie wliczaj bajtu NULL do długości

no0:
    movl    %edx, %eax          # eax = początkowy maksymalny limit
    subl    %ecx, %eax          # Oblicz liczbę przeszukanych bajtów: eax = edx - ecx
    
    popl    %edi
    popl    %ebp
    ret