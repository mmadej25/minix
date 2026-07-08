# lib/sysutil/CMakeLists.txt

add_library(
  sysutil STATIC
  kmalloc.c
  kprintf.c
  kputc.c
  tickdelay.c
  getuptime.c
  env_get_prm.c
  env_parse.c
  env_panic.c
  env_prefix.c
  fkey_ctl.c
  panic.c
  report.c
  taskcall.c)

target_compile_definitions(sysutil PRIVATE _MINIX _POSIX_SOURCE)

target_include_directories(sysutil PRIVATE ${CMAKE_SOURCE_DIR}/include)
