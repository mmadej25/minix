# src/kernel/CMakeLists.txt

# Tworzymy bibliotekę statyczną z plików, które chcesz teraz przeczytać i naprawić
add_library(minix_kernel STATIC
    clock.c
    i8259.c
    exception.c
    debug.c
    main.c
    proc.c
    protect.c
    start.c
    system.c
    table.c
    utility.c
)
