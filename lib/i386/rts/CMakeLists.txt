# ==============================================================================
# lib/i386/rts/CMakeLists.txt
# CMake configuration for the low-level architecture-specific library
# ==============================================================================


add_library(rts STATIC
    _ipc_att.S
)

# Ensure the library targets the correct architecture and compiler flags
target_compile_options(rts PRIVATE "-m32")

