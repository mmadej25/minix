# lib/i386/fphook/CMakeLists.txt

# Define files for the standard libc (these "tricks" limit the size)
set(FPHOOK_LIBC_SOURCES fltpr.c strtod.c)

# We're creating a static library fphook, which will be part of libc
add_library(fphook STATIC ${FPHOOK_LIBC_SOURCES})

# Path to global headers include/
target_include_directories(fphook
                           PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../include)

# -------------------------------------------------------------------
# Optionally: Real fphook for programs using mathematics (libd.a)
# -------------------------------------------------------------------
add_library(fphook_real STATIC fphook.c)
target_compile_definitions(fphook_real PRIVATE _MINIX _POSIX_SOURCE)
target_compile_options(fphook_real PRIVATE -O2 -ffreestanding)
target_include_directories(fphook_real
                           PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../include)
set_target_properties(fphook_real PROPERTIES OUTPUT_NAME "d")
