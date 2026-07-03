# ==============================================================================
# lib/posix/CMakeLists.txt
# CMake configuration for the low-level architecture-specific library
# ==============================================================================


add_library(posix STATIC
    _sigset.c
)

# Ensure the library targets the correct architecture and compiler flags
target_compile_options(posix PRIVATE "-m32")
