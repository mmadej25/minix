# lib/end/CMakeLists.txt

add_library(end STATIC edata_att.S em_end_att.S end_att.S etext_att.S)

set_target_properties(end PROPERTIES LINKER_LANGUAGE C)
