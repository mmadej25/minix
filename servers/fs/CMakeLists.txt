add_library(minix_fs STATIC
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
    utility.c
    write.c
)

target_compile_definitions(minix_fs PRIVATE 
    _SERVER
    _MINIX
)

target_include_directories(minix_fs PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}
)
