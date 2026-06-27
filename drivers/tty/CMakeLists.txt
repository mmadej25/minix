add_library(minix_tty STATIC
    console.c
    keyboard.c
    pty.c
    rs232.c
    tty.c
    vidcopy_att.S
)

target_compile_definitions(minix_fs PRIVATE 
    _SERVER
    _MINIX
)

target_include_directories(minix_fs PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}
)

