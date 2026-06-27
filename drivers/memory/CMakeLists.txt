add_library(minix_memory STATIC
    memory.c
)

target_compile_definitions(minix_fs PRIVATE 
    _SERVER
    _MINIX
)

target_include_directories(minix_fs PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}
)

