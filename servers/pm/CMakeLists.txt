# src/servers/pm/CMakeLists.txt

add_executable(
  pm
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

target_link_options(
  pm
  PRIVATE
  "-T"
  "${CMAKE_CURRENT_SOURCE_DIR}/pm.ld"
  "-static"
  "-nostdlib"
  "-Wl,--gc-sections")

# Generate a linker symbol map file for debugging purposes
target_link_options(pm PRIVATE "-Wl,-Map=pm.map")

target_link_libraries(
  pm
  PRIVATE -Wl,--start-group
          rts
          posix
          misc
          string
          timers
          ansi
          -Wl,--end-group
          syslib
          sysutil
          end
          other)
