add_library(minix_log STATIC
    diag.c
    kputc.c
    log.c
)

target_compile_definitions(minix_log PRIVATE 
    _SERVER
    _MINIX
)

target_include_directories(minix_log PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}
)


