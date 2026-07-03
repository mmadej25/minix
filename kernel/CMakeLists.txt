# ==============================================================================
# kernel/CMakeLists.txt
# CMake configuration for the low-level architecture-specific library
# ==============================================================================

add_executable(
  kernel
  clock.c
  i8259.c
  exception.c
  debug.c
  main.c
  mpx386_att.S
  klib386_att.S
  proc.c
  protect.c
  start.c
  system.c
  table.c
  utility.c
  system/do_abort.c
  system/do_copy.c
  system/do_devio.c
  system/do_endksig.c
  system/do_exec.c
  system/do_exit.c
  system/do_fork.c
  system/do_getinfo.c
  system/do_getksig.c
  system/do_int86.c
  system/do_irqctl.c
  system/do_kill.c
  system/do_memset.c
  system/do_newmap.c
  system/do_nice.c
  system/do_privctl.c
  system/do_sdevio.c
  system/do_segctl.c
  system/do_setalarm.c
  system/do_sigreturn.c
  system/do_sigsend.c
  system/do_times.c
  system/do_trace.c
  system/do_umap.c
  system/do_unused.c
  system/do_vcopy.c
  system/do_vdevio.c)

# Target link options: enforce custom linker script and freestanding environment
target_link_options(kernel PRIVATE "-T" "${CMAKE_CURRENT_SOURCE_DIR}/kernel.ld"
                    "-nostdlib" "-Wl,--gc-sections")

# Generate a linker symbol map file for debugging purposes
target_link_options(kernel PRIVATE "-Wl,-Map=kernel.map")

target_link_libraries(kernel PRIVATE misc)
target_link_libraries(kernel PRIVATE string)
target_link_libraries(kernel PRIVATE rts)
target_link_libraries(kernel PRIVATE timers)
target_link_libraries(kernel PRIVATE ansi)
target_link_libraries(kernel PRIVATE other)
target_link_libraries(kernel PRIVATE posix)
