# src/servers/pm/CMakeLists.txt

add_library(
  minix_pm STATIC
  alloc.c
  break.c
  exec.c
  forkexit.c
  getset.c
  main.c
  misc.c
  signal.c
  table.c
  time.c
  timers.c
  trace.c
  utility.c)
