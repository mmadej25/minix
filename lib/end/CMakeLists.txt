# lib/end/CMakeLists.txt

# Tworzymy bibliotekę statyczną z plików asemblera
add_library(end STATIC
  edata_att.S
  em_end_att.S
  end_att.S
  etext_att.S
)

# Upewniamy się, że CMake wie, jak traktować pliki .S z preprocesorem
set_target_properties(end PROPERTIES LINKER_LANGUAGE C)
