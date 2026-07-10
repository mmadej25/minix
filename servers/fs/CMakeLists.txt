add_executable(
  fs
  cache.c
  cache2.c
  cdprobe.c
  device.c
  dmap.c
  filedes.c
  inode.c
  link.c
  lock.c
  main.c
  misc.c
  mount.c
  open.c
  path.c
  pipe.c
  protect.c
  read.c
  select.c
  stadir.c
  super.c
  table.c
  time.c
  timers.c
  utility.c
  write.c)

target_compile_definitions(fs PRIVATE _SERVER _MINIX)

target_include_directories(fs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_options(
  fs
  PRIVATE
  "-T"
  "${CMAKE_CURRENT_SOURCE_DIR}/fs.ld"
  "-static"
  "-nostdlib"
  "-Wl,--gc-sections")

# Generate a linker symbol map file for debugging purposes
target_link_options(fs PRIVATE "-Wl,-Map=fs.map")

# Linkowanie bibliotek w poprawnej kolejności (od konsumentów do dostawców)
# Jeden spójny blok definiujący właściwą i bezpieczną kolejność linkowania dla
# fs
target_link_libraries(
  fs
  # --- GROUP RESOLVING CIRCULAR DEPENDENCIES (stdio <-> fphook) ---
  -Wl,--start-group
  rts
  syslib
  sysutil
  ansi
  posix
  stdio
  fphook
  other
  -Wl,--end-group
  string
  misc
  timers
  end)
