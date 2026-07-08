# lib/sysutil/CMakeLists.txt

add_library(sysutil STATIC
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
  taskcall.c
)

# Definiujemy makra kompilacji, które były obecne w oryginalnym Makefile (-D_MINIX -D_POSIX_SOURCE)
target_compile_definitions(sysutil PRIVATE
  _MINIX
  _POSIX_SOURCE
)

# Zapewniamy dostęp do globalnych nagłówków MINIX-a (np. include/)
target_include_directories(sysutil PRIVATE ${CMAKE_SOURCE_DIR}/include)
