# lib/other/CMakeLists.txt

add_library(other STATIC errno.c syscall.c loadname.c environ.c _svrctl.c
                         _brk.c)
