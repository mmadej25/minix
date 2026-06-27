cmake_minimum_required(VERSION 3.20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
project(MinixOverhaul LANGUAGES C CXX ASM)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)

add_compile_options(
    -march=i686
    -m32                     # Kompilacja 32-bitowa (architektura x86 MINIX-a)
    -ffreestanding           # Brak standardowych bibliotek/nagłówków hosta
    -fno-builtin             # Wyłączenie wbudowanych funkcji optymalizacyjnych GCC
    -fno-strict-aliasing     # Kluczowe dla niskopoziomowych manipulacji wskaźnikami w jądre
    -Wall
    -Wextra
)

add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>)
add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>)

add_compile_definitions(
    _POSIX_SOURCE=1 
    _MINIX=1 
    _EM_WSIZE=4
)

include_directories(include)

add_subdirectory(kernel)
add_subdirectory(servers/pm)
add_subdirectory(servers/fs)
add_subdirectory(servers/rs)
add_subdirectory(drivers/tty)

