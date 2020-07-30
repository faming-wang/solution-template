target_compile_options(common_options
INTERFACE
    $<IF:$<CONFIG:Debug>,,-fno-strict-aliasing>
    -pipe
    -Wall
    -W
    -fPIC
    -Wno-unused-variable
    -Wno-unused-parameter
    -Wno-unused-function
    -Wno-switch
    -Wno-comment
    -Wno-unused-but-set-variable
    -Wno-missing-field-initializers
    -Wno-sign-compare
    -Wno-attributes
    -Wno-parentheses
    -Wno-stringop-overflow
    -Wno-maybe-uninitialized
    -Wno-error=class-memaccess
)

target_compile_options(common_options
  INTERFACE
    $<IF:$<CONFIG:Debug>,,-Ofast>
    -Werror
)
target_link_options(common_options
  INTERFACE
    $<IF:$<CONFIG:Debug>,,-Ofast>
)
