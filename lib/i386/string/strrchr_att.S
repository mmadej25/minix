# strrchr.S - Szukanie ostatniego wystąpienia znaku w ciągu (wersja zoptymalizowana x86)
# Dostosowane do i686-elf-gcc (składnia AT&T, usunięty wiodący podkreślnik dla formatu ELF)

.global strrchr

.text
.align 16
strrchr:
    pushl   %ebp
    movl    %esp, %ebp
    pushl   %edi
    
    movl    8(%ebp), %edi       # edi = wskaźnik na string (s)
    movl    $-1, %ecx           # ecx = -1 (licznik dla repne)
    xorb    %al, %al            # al = 0 (szukamy końca stringu '\0')
    
    cld                         # Przeszukiwanie w przód
    repne   scasb               # Szukaj końca ciągu
    
    notl    %ecx                # ecx = długość stringu wraz z bajtem NULL
    decl    %edi                # Cofnij edi, aby wskazywał dokładnie na bajt NULL
    
    movb    12(%ebp), %al       # al = szukany znak (c)
    std                         # Zmiana kierunku: przeszukiwanie w tył (od końca)
    repne   scasb               # Szukaj znaku idąc wstecz
    
    cld                         # Przywróć domyślny kierunek (wymagane przez ABI!)
    jne     failure             # Jeśli nie znaleziono, skocz do failure
    
    leal    1(%edi), %eax       # Znaleziono: edi po scasb cofnął się o 1 za daleko, więc dodajemy 1
    popl    %edi
    popl    %ebp
    ret

failure:
    xorl    %eax, %eax          # Zwróć NULL (0)
    popl    %edi
    popl    %ebp
    ret