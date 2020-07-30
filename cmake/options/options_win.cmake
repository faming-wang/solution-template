target_compile_definitions(common_options
  INTERFACE
    _SCL_SECURE_NO_WARNINGS
    _CRT_SECURE_NO_WARNINGS
    NOMINMAX
    UNICODE
    _UNICODE
)

target_compile_features(common_options INTERFACE cxx_std_17)
# if (MSVC_VERSION GREATER_EQUAL "1900")
#     include(CheckCXXCompilerFlag)
#     CHECK_CXX_COMPILER_FLAG("/std:c++latest" _cpp_latest_flag_supported)
#     if (_cpp_latest_flag_supported)
#         target_compile_options(common_defines INTERFACE "/std:c++latest")
#     endif()
# endif()

target_compile_options(common_options
  INTERFACE
    /W1
    /W3
    /WX-
    /MP     # Enable multi process build.
    /EHsc   # Catch C++ exceptions only, extern C functions never throw a C++ exception.
    /w14834 # [[nodiscard]]
    /w15038 # wrong initialization order
    /w14265 # class has virtual functions, but destructor is not virtual
    /wd4068 # Disable "warning C4068: unknown pragma"
    # /wd4819 # Disable "warning C4819: file is not unicode"
    /wd4086
    /wd4577
    /wd4467
    # /Zc:wchar_t- # don't tread wchar_t as builtin type
    /permissive-
    /Zi
)

if (NOT BUILD_STATIC_LIBRARY)
  target_compile_options(common_options INTERFACE /wd4251)
endif()

target_link_options(common_options
  INTERFACE
    $<IF:$<CONFIG:Debug>,/NODEFAULTLIB:LIBCMT,/DEBUG;/OPT:REF>
)

target_link_libraries(common_options
  INTERFACE
    winmm
    imm32
    ws2_32
    kernel32
    user32
    gdi32
    winspool
    comdlg32
    advapi32
    shell32
    ole32
    oleaut32
    uuid
    odbc32
    odbccp32
    Shlwapi
    Iphlpapi
    Gdiplus
    Strmiids
    Netapi32
    Userenv
    Version
    Dwmapi
    Wtsapi32
    UxTheme
    DbgHelp
    Rstrtmgr
    Crypt32
    Normaliz
)


