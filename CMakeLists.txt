cmake_minimum_required(VERSION 3.20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
project(MinixOverhaul LANGUAGES C CXX ASM)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)

add_compile_options(
  -march=i686
  -m32
  -ffreestanding
  -fno-builtin
  -fno-strict-aliasing
  -Wall
  -Wextra)

add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>)
add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>)

add_compile_definitions(_POSIX_SOURCE=1 _MINIX=1 _EM_WSIZE=4)

include_directories(include)

add_subdirectory(servers/pm)
add_subdirectory(servers/fs)
add_subdirectory(servers/rs)
add_subdirectory(servers/init)
add_subdirectory(drivers/tty)
add_subdirectory(drivers/memory)
add_subdirectory(drivers/log)
add_subdirectory(drivers/at_wini)
add_subdirectory(lib/ansi)
add_subdirectory(lib/other)
add_subdirectory(lib/posix)
add_subdirectory(lib/i386/misc)
add_subdirectory(lib/i386/string)
add_subdirectory(lib/i386/rts)
add_subdirectory(lib/timers)
add_subdirectory(lib/syslib)
add_subdirectory(lib/sysutil)
add_subdirectory(lib/end)
add_subdirectory(lib/fphook)
add_subdirectory(kernel)

find_program(CMAKE_FORMAT_PROGRAM cmake-format)

if(CMAKE_FORMAT_PROGRAM)
  file(
    GLOB_RECURSE CMAKE_FILES
    LIST_DIRECTORIES false
    "CMakeLists.txt" "*.cmake")

  add_custom_target(
    format
    COMMAND ${CMAKE_FORMAT_PROGRAM} -i ${CMAKE_FILES}
    COMMENT "Format CMake scripts using cmake-format...")
else()
  message(WARNING "Couldn't find cmake-format.")
endif()
