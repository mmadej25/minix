# ==============================================================================
# lib/posix/CMakeLists.txt CMake configuration for the low-level
# architecture-specific library
# ==============================================================================

add_library(
  posix STATIC
  _sigset.c
  _open.c
  _close.c
  _lseek.c
  _read.c
  _write.c
  _access.c
  _fstat.c
  __exit.c)

# Ensure the library targets the correct architecture and compiler flags
target_compile_options(posix PRIVATE "-m32")
