# CMakeLists.txt (Główny)
cmake_minimum_required(VERSION 3.20)
project(MinixOverhaul LANGUAGES C CXX ASM)

# Wymuszenie standardów (C99 dla starego kodu, C++17 pod Twoje przepisywanie)
set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)

# Krytyczne flagi bare-metal dla GCC
add_compile_options(
    -march=i686
    -m32                     # Kompilacja 32-bitowa (architektura x86 MINIX-a)
    -ffreestanding           # Brak standardowych bibliotek/nagłówków hosta
    -fno-builtin             # Wyłączenie wbudowanych funkcji optymalizacyjnych GCC
    -fno-strict-aliasing     # Kluczowe dla niskopoziomowych manipulacji wskaźnikami w jądre
    -Wall
    -Wextra
)

# Flagi specyficzne WYŁĄCZNIE dla C++ (wyłączamy RTTI i wyjątki w jądre)
add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>)
add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>)

# Definicje preprocesora z master nagłówka kernel.h
add_compile_definitions(
    _POSIX_SOURCE=1 
    _MINIX=1 
    _SYSTEM=1
    _EM_WSIZE=4
)

# Ścieżki do plików nagłówkowych (.h) MINIX-a
# (Załóżmy, że oryginalne pliki wrzucisz do katalogu include/ i src/kernel/)
include_directories(include)

# Podpinamy podkatalog z kodem źródłowym samego jądra
add_subdirectory(kernel)
add_subdirectory(servers/pm)
