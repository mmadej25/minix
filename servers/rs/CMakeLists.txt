# src/servers/rs/CMakeLists.txt
add_library(minix_rs STATIC manager.c rs.c service.c)

target_compile_definitions(minix_rs PRIVATE _SERVER _MINIX)
target_include_directories(minix_rs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
