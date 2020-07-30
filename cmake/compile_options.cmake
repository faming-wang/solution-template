

include(project_variables)

add_library(common_options INTERFACE)
add_library(${APP_CASED_ID}::common_options ALIAS common_options)

target_compile_definitions(common_options
  INTERFACE
    $<IF:$<CONFIG:Debug>,_DEBUG,NDEBUG>
)
if (WIN32)
  include(cmake/options/options_win.cmake)
elseif (APPLE)
  include(cmake/options/options_mac.cmake)
elseif (LINUX)
  include(cmake/options/options_linux.cmake)
else()
  message(FATAL_ERROR "Unknown platform type")
endif()


add_library(default_defines INTERFACE)
add_library(options::default_defines ALIAS default_defines)
target_compile_definitions(default_defines INTERFACE
  $<IF:$<CONFIG:Debug>,_DEBUG,NDEBUG>
)
target_compile_features(default_defines INTERFACE cxx_std_17)
if (WIN32)
  target_compile_definitions(default_defines INTERFACE
    UNICODE
    _UNICODE
    _CRT_SECURE_NO_WARNINGS
    WINVER=0x0602
    _WIN32_WINNT=0x0602
    WIN32_LEAN_AND_MEAN
  )
endif()

add_library(qt_default_defines INTERFACE)
add_library(options::qt_default_defines ALIAS qt_default_defines)
target_compile_definitions(qt_default_defines INTERFACE
  QT_NO_JAVA_STYLE_ITERATORS
  QT_NO_CAST_TO_ASCII
  QT_RESTRICTED_CAST_FROM_ASCII
  QT_DISABLE_DEPRECATED_BEFORE=0x050900
  QT_USE_FAST_OPERATOR_PLUS
  QT_USE_FAST_CONCATENATION
)
