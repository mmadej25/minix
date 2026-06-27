# i686-elf-toolchain.cmake

# Wymuszamy, by CMake sprawdzał tylko samą kompilację do pliku obiektowego, pomijając linkowanie testu
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR i686)

# Wskazujemy ścieżki do cross-narzędzi wygenerowanych przez crossdev
set(CMAKE_C_COMPILER i686-elf-gcc)
set(CMAKE_CXX_COMPILER i686-elf-g++)
set(CMAKE_ASM_COMPILER i686-elf-gcc)

# Zabezpieczenie przed szukaniem bibliotek w systemie hosta (Gentoo)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
