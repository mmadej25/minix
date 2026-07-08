# lib/syslib/CMakeLists.txt

add_library(syslib STATIC
  sys_times.c
  sys_abort.c
  sys_exec.c
  sys_fork.c
  sys_int86.c
  sys_kill.c
  sys_newmap.c
  sys_sigsend.c
  sys_sigreturn.c
  sys_endsig.c
  sys_getsig.c
  sys_svrctl.c
  sys_trace.c
  sys_exit.c
  sys_sdevio.c
  sys_getinfo.c
  sys_irqctl.c
  sys_segctl.c
  sys_nice.c
  sys_umap.c
  sys_physcopy.c
  sys_vircopy.c
  sys_in.c
  sys_out.c
  sys_vinb.c
  sys_vinw.c
  sys_vinl.c
  sys_voutb.c
  sys_voutw.c
  sys_voutl.c
  sys_setalarm.c
  sys_memset.c
  taskcall.c
)

target_include_directories(syslib PRIVATE ${CMAKE_SOURCE_DIR}/include)
