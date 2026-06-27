add_library(minix_init STATIC init.c)

target_compile_definitions(minix_init PRIVATE _SERVER _MINIX)
target_include_directories(minix_init PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
