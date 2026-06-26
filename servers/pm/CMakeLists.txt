# src/servers/pm/CMakeLists.txt

# Tworzymy osobną bibliotekę statyczną dla Process Managera
add_library(minix_pm STATIC
    alloc.c
    break.c
    exec.c
    forkexit.c
    getset.c
    main.c
    misc.c
    signal.c
    table.c
    time.c
    timers.c
    trace.c
    utility.c
)

# Jeśli PM potrzebuje specyficznych definicji preprocesora, dodajemy je tutaj:
#target_compile_definitions(minix_pm PRIVATE _SERVER)
