# ==============================================================================
# lib/i386/string/CMakeLists.txt CMake configuration for the low-level
# architecture-specific library
# ==============================================================================

add_library(
  string STATIC
  _strncpy_att.S
  strncpy_att.S
  _strncmp_att.S
  strncmp_att.S
  strcmp_att.S
  memcpy_att.S
  memmove_att.S
  _memmove_att.S
  memchr_att.S
  memset_att.S
  strrchr_att.S
  strlen_att.S
  strcpy_att.S
  _strnlen_att.S)

# Ensure the library targets the correct architecture and compiler flags
target_compile_options(string PRIVATE "-m32")
