# ==============================================================================
# lib/i386/misc/CMakeLists.txt
# CMake configuration for the low-level architecture-specific library
# ==============================================================================


add_library(misc STATIC
    io_inb_att.S
    io_outb_att.S
    io_inw_att.S
    io_outw_att.S
    io_inl_att.S
    io_outl_att.S
    io_intr_att.S
)

# Ensure the library targets the correct architecture and compiler flags
target_compile_options(misc PRIVATE "-m32")
