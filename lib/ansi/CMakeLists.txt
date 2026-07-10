# ==============================================================================
# lib/ansi/CMakeLists.txt CMake configuration for the low-level
# architecture-specific library
# ==============================================================================

add_library(ansi STATIC atoi.c strtol.c chartab.c toupper.c exit.c malloc.c)

# Ensure the library targets the correct architecture and compiler flags
target_compile_options(ansi PRIVATE "-m32")
