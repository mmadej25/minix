# ==============================================================================
# lib/timers/CMakeLists.txt
# CMake configuration for the generic watchdog timer and low-level IO library
# ==============================================================================

set(TIMERS_C_SOURCES
    tmrs_set.c
    tmrs_clr.c
    tmrs_exp.c
)


add_library(timers STATIC
    ${TIMERS_C_SOURCES}
)


set_target_properties(timers PROPERTIES
    OUTPUT_NAME "timers"
    PREFIX "lib"
)

target_compile_options(timers PRIVATE 
    "-m32"
    "-O2"
    "-march=i686"
)
target_compile_definitions(timers PRIVATE
    _MINIX
    _POSIX_SOURCE
)

target_compile_options(timers PRIVATE $<$<COMPILE_LANGUAGE:ASM>:-m32>)

target_include_directories(timers PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
