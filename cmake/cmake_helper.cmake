include(compile_options)

function(_nice_target_sources _target src_loc)
  cmake_parse_arguments(_arg "INTERFACE;PUBLIC;PRIVATE" "" "SORUCES" ${ARGN})
  if (${_arg_UNPARSED_ARGUMENTS})
    message(FATAL_ERROR "_nice_target_sources had unparsed arguments")
  endif()

  set(SOURCE_TYPE PRIVATE)
  if(${_arg_INTERFACE})
    set(SOURCE_TYPE INTERFACE)
  elseif(${_arg_PUBLIC})
    set(SOURCE_TYPE PUBLIC)
  endif()

  set(src_list ${_arg_SORUCES})
  set(not_win_sources "")
  set(not_mac_sources "")
  set(not_linux_sources "")

  foreach (entry IN LISTS src_list)
    set(full_name ${src_loc}/${entry})
    if (${entry} MATCHES "(^|/)win/" OR ${entry} MATCHES "(^|/)winrc/" OR ${entry} MATCHES "(^|/)windows/" OR ${entry} MATCHES "[_\\/]win\\.")
        list(APPEND not_mac_sources ${full_name})
        list(APPEND not_linux_sources ${full_name})
    elseif (${entry} MATCHES "(^|/)mac/" OR ${entry} MATCHES "(^|/)darwin/" OR ${entry} MATCHES "(^|/)osx/" OR ${entry} MATCHES "[_\\/]mac\\." OR ${entry} MATCHES "[_\\/]darwin\\." OR ${entry} MATCHES "[_\\/]osx\\.")
        list(APPEND not_win_sources ${full_name})
        list(APPEND not_linux_sources ${full_name})
    elseif (${entry} MATCHES "(^|/)linux/" OR ${entry} MATCHES "[_\\/]linux\\.")
        list(APPEND not_win_sources ${full_name})
        list(APPEND not_mac_sources ${full_name})
    elseif (${entry} MATCHES "(^|/)posix/" OR ${entry} MATCHES "[_\\/]posix\\.")
        list(APPEND not_win_sources ${full_name})
    endif()

    target_sources(${_target} ${SOURCE_TYPE} ${full_name})

    if (${src_loc} MATCHES "/resources$" OR ${entry} MATCHES "\.qrc$|\.rc$|\.txt$|\.strings$")
        source_group(TREE ${src_loc} PREFIX Resources FILES ${full_name})
    else()
        source_group(TREE ${src_loc} PREFIX Sources FILES ${full_name})
    endif()

    if(${entry} MATCHES "\.ui$")
      set_source_files_properties(${full_name} PROPERTIES AUTOUIC ON)
    endif()
  endforeach()

  if (WIN32)
      set_source_files_properties(${not_win_sources} PROPERTIES HEADER_FILE_ONLY TRUE)
      set_source_files_properties(${not_win_sources} PROPERTIES SKIP_AUTOGEN TRUE)
  elseif (APPLE)
      set_source_files_properties(${not_mac_sources} PROPERTIES HEADER_FILE_ONLY TRUE)
      set_source_files_properties(${not_mac_sources} PROPERTIES SKIP_AUTOGEN TRUE)
  elseif (LINUX)
      set_source_files_properties(${not_linux_sources} PROPERTIES HEADER_FILE_ONLY TRUE)
      set_source_files_properties(${not_linux_sources} PROPERTIES SKIP_AUTOGEN TRUE)
  endif()
endfunction()

function(nice_target_sources _target _src_loc)
  cmake_parse_arguments(_arg "" "" "INTERFACE;PUBLIC;PRIVATE" ${ARGN})
  _nice_target_sources(${_target} ${_src_loc} INTERFACE SORUCES ${_arg_INTERFACE})
  _nice_target_sources(${_target} ${_src_loc} PUBLIC    SORUCES ${_arg_PUBLIC})
  _nice_target_sources(${_target} ${_src_loc} PRIVATE   SORUCES ${_arg_PRIVATE})
endfunction()

function(target_source_group src_loc file)
  get_filename_component(full_path ${file} REALPATH)
  file(RELATIVE_PATH rela_path "${src_loc}" "${full_path}")

  get_filename_component(parent_path ${full_path} DIRECTORY)
  file(RELATIVE_PATH parent_path "${src_loc}" "${parent_path}")

  string(REPLACE "${src_loc}" "" group "${parent_path}")
  string(REPLACE "/" "\\" group "${group}")

  if (${rela_path} MATCHES "\.qrc$|\.rc$|\.txt$|\.strings$" OR ${full_path} MATCHES "[\\/]resources\\/" OR ${full_path} MATCHES "(^|/)resources\\/")
    source_group("Resources\\${group}" FILES "${rela_path}")
  else()
    source_group("Sources\\${group}" FILES "${rela_path}")
  endif()
endfunction()

function(target_source_tree _target _sources)
  get_filename_component(_src_loc ${CMAKE_CURRENT_SOURCE_DIR} REALPATH)
  foreach(_file IN LISTS _sources)
    target_sources(${_target} PRIVATE ${_file})
    target_source_group(${_src_loc} ${_file})
  endforeach()
endfunction()

function(aux_public_headers _out_list _sources)
  foreach(source IN LISTS _sources)
    if (source MATCHES "\.h$|\.hpp$")
      list(APPEND _temp_list ${source})
    endif()
  endforeach()
  set(${_out_list} ${_temp_list} PARENT_SCOPE)
endfunction()

function(add_configure_file _target)
  cmake_parse_arguments(_arg
    "STATIC" ""
    "PUBLIC_HEADERS" ${ARGN}
  )
  # 配置文件
  string(TOUPPER "${_target}_STATIC_LIBRARY" _static_export_symbol)
  if(_arg_STATIC)
    set(${_static_export_symbol} "#define ${_static_export_symbol}")
  else()
    set(${_static_export_symbol} "// #define ${_static_export_symbol}")
  endif()
  string(TOLOWER "${_target}" _configure_file_name)

  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/${_configure_file_name}.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/${_configure_file_name}.h
  )

  # 写入PCH文件列表
  foreach(_file IN LISTS _arg_PUBLIC_HEADERS)
    string(APPEND _public_headers_str "#include <${_configure_file_name}/${_file}>\n")
  endforeach()
  file(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/${_configure_file_name}_pch.h
    "#pragma once\n\n"
    "#include <${_configure_file_name}/${_configure_file_name}.h>\n"
    "${_public_headers_str}"
  )
endfunction()

function(init_target _target)
  cmake_parse_arguments(_arg "" ""
    "INCLUDES;PUBLIC_INCLUDES;DEFINES;PUBLIC_DEFINES;OPTIONS;PUBLIC_OPTIONS;DEPENDS;PUBLIC_DEPENDS;PROPERTIES"
    ${ARGN}
  )
  target_compile_definitions(${_target} PRIVATE ${APP_DEFAULT_DEFINES})
  #
  target_include_directories(${_target} PRIVATE ${_arg_INCLUDES} PUBLIC ${_arg_PUBLIC_INCLUDES})
  target_compile_definitions(${_target} PRIVATE ${_arg_DEFINES} PUBLIC ${_arg_PUBLIC_DEFINES})
  target_compile_options(${_target} PRIVATE ${_arg_OPTIONS} PUBLIC ${_arg_PUBLIC_OPTIONS})
  target_link_libraries(${_target} PRIVATE ${_arg_DEPENDS} PUBLIC ${_arg_PUBLIC_DEPENDS})
  set_target_properties(${_target} PROPERTIES ${_arg_PROPERTIES})
endfunction()

function(add_app_library _target)
  cmake_parse_arguments(_arg "STATIC;OBJECT;INTERFACE" "NAMESPACE"
    "INCLUDES;PUBLIC_INCLUDES;DEFINES;PUBLIC_DEFINES;OPTIONS;PUBLIC_OPTIONS;DEPENDS;PUBLIC_DEPENDS;PROPERTIES"
    ${ARGN}
  )
  if (${_arg_UNPARSED_ARGUMENTS})
    message(FATAL_ERROR "add_app_library had unparsed arguments")
  endif()

  set(library_type SHARED)
  if (_arg_STATIC)
    set(library_type STATIC)
  elseif(_arg_OBJECT)
    set(library_type OBJECT)
  elseif(_arg_INTERFACE)
    set(library_type INTERFACE)
  endif()

  set(LIB_NAMESPACE ${APP_CASED_ID})
  if (_arg_NAMESPACE)
    set(LIB_NAMESPACE ${_arg_NAMESPACE})
  endif()

  add_library(${_target} ${library_type})
  add_library(${LIB_NAMESPACE}::${_target} ALIAS ${_target})
  init_target(${_target}
    INCLUDES ${_arg_INCLUDES}
    PUBLIC_INCLUDES ${_arg_PUBLIC_INCLUDES}
    DEFINES ${_arg_DEFINES}
    PUBLIC_DEFINES ${_arg_PUBLIC_DEFINES}
    OPTIONS ${_arg_OPTIONS}
    PUBLIC_OPTIONS ${_arg_PUBLIC_OPTIONS}
    DEPENDS ${_arg_DEPENDS}
    PUBLIC_DEPENDS ${_arg_PUBLIC_DEPENDS}
    PROPERTIES ${_arg_PROPERTIES}
      VERSION "${APP_VERSION}"
      BUILD_RPATH "${_LIB_RPATH}"
      INSTALL_RPATH "${_LIB_RPATH}"
      RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${APP_BIN_PATH}"
      LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${APP_LIBRARY_PATH}"
      ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${APP_LIBRARY_PATH}"
  )

  unset(NAMELINK_OPTION)
  if (library_type STREQUAL "SHARED")
    set(NAMELINK_OPTION NAMELINK_SKIP)
  endif()

  install(TARGETS ${_target}
    EXPORT ${APP_CASED_ID}
    RUNTIME DESTINATION "${_DESTINATION}" OPTIONAL
    LIBRARY
      DESTINATION "${APP_LIBRARY_PATH}"
      ${NAMELINK_OPTION}
      OPTIONAL
    OBJECTS
      DESTINATION "${APP_LIBRARY_PATH}"
      COMPONENT Devel EXCLUDE_FROM_ALL
    ARCHIVE
      DESTINATION "${APP_LIBRARY_PATH}"
      COMPONENT Devel EXCLUDE_FROM_ALL
      OPTIONAL
  )

  if (NAMELINK_OPTION)
    install(TARGETS ${_target}
      LIBRARY
        DESTINATION "${APP_LIBRARY_PATH}"
        NAMELINK_ONLY
        COMPONENT Devel EXCLUDE_FROM_ALL
        OPTIONAL
    )
  endif()
endfunction()

function(add_app_exec _target)
  cmake_parse_arguments(_arg "" "NAMESPACE"
    "DEFINES;DEPENDS;OPTIONS;INCLUDES;PROPERTIES" ${ARGN}
  )
  if (${_arg_UNPARSED_ARGUMENTS})
    message(FATAL_ERROR "add_app_exec had unparsed arguments")
  endif()

  set(APP_NAMESPACE ${APP_CASED_ID})
  if (_arg_NAMESPACE)
    set(APP_NAMESPACE ${_arg_NAMESPACE})
  endif()

  string(TOUPPER "BUILD_EXECUTABLE_${_target}" _build_executable_var)

  set(_build_executable_default "ON")
  if (DEFINED ENV{QTC_${_build_executable_var}})
    set(_build_executable_default "$ENV{QTC_${_build_executable_var}}")
  endif()
  set(${_build_executable_var} "${_build_executable_default}" CACHE BOOL "Build executable ${_target}.")

  if (NOT ${_build_executable_var})
    return()
  endif()

  set(_EXECUTABLE_PATH "${APP_LIBEXEC_PATH}")
  if (APPLE)
    # path of executable might be inside app bundle instead of DESTINATION directly
    cmake_parse_arguments(_prop "" "MACOSX_BUNDLE;OUTPUT_NAME" "" "${_arg_PROPERTIES}")
    if (_prop_MACOSX_BUNDLE)
      set(_BUNDLE_NAME "${_target}")
      if (_prop_OUTPUT_NAME)
        set(_BUNDLE_NAME "${_prop_OUTPUT_NAME}")
      endif()
      set(_EXECUTABLE_PATH "${APP_LIBEXEC_PATH}/${_BUNDLE_NAME}.app/Contents/MacOS")
    endif()
  endif()

  file(RELATIVE_PATH _RELATIVE_LIB_PATH "/${_EXECUTABLE_PATH}" "/${APP_LIBRARY_PATH}")

  add_executable(${_target})
  init_target(${_target}
    PUBLIC_INCLUDES ${_arg_INCLUDES}
    PUBLIC_DEFINES ${_arg_DEFINES}
    PUBLIC_OPTIONS ${_arg_OPTIONS}
    PUBLIC_DEPENDS ${_arg_DEPENDS}
    PROPERTIES ${_arg_PROPERTIES}
      BUILD_RPATH "${_RPATH_BASE}/${_RELATIVE_LIB_PATH}"
      INSTALL_RPATH "${_RPATH_BASE}/${_RELATIVE_LIB_PATH}"
      RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${APP_LIBEXEC_PATH}"
  )
  install(TARGETS ${_target} DESTINATION "${APP_LIBEXEC_PATH}" OPTIONAL)
endfunction()

function(add_qml_plugin _target)
  cmake_parse_arguments(_arg "STATIC;OBJECT;INTERFACE" "NAMESPACE;QML_DIR;QML_MODULE"
    "INCLUDES;PUBLIC_INCLUDES;DEFINES;PUBLIC_DEFINES;OPTIONS;PUBLIC_OPTIONS;DEPENDS;PUBLIC_DEPENDS;PROPERTIES"
    ${ARGN}
  )
  if (${_arg_UNPARSED_ARGUMENTS})
    message(FATAL_ERROR "add_app_library had unparsed arguments")
  endif()

  set(library_type SHARED)
  if (_arg_STATIC)
    set(library_type STATIC)
  elseif(_arg_OBJECT)
    set(library_type OBJECT)
  elseif(_arg_INTERFACE)
    set(library_type INTERFACE)
  endif()

  set(LIB_NAMESPACE ${APP_CASED_ID})
  if (_arg_NAMESPACE)
    set(LIB_NAMESPACE ${_arg_NAMESPACE})
  endif()

  add_library(${_target} ${library_type})
  add_library(${LIB_NAMESPACE}::${_target} ALIAS ${_target})

  set(QML_OUTPUT_DIRECTORY "qml/${_arg_QML_MODULE}")

  init_target(${_target}
    INCLUDES ${_arg_INCLUDES}
    PUBLIC_INCLUDES ${_arg_PUBLIC_INCLUDES}
    DEFINES ${_arg_DEFINES}
    PUBLIC_DEFINES ${_arg_PUBLIC_DEFINES}
    OPTIONS ${_arg_OPTIONS}
    PUBLIC_OPTIONS ${_arg_PUBLIC_OPTIONS}
    DEPENDS ${_arg_DEPENDS}
    PUBLIC_DEPENDS ${_arg_PUBLIC_DEPENDS}
    PROPERTIES ${_arg_PROPERTIES}
      VERSION "${APP_VERSION}"
      BUILD_RPATH "${_LIB_RPATH}/${QML_OUTPUT_DIRECTORY}"
      INSTALL_RPATH "${_LIB_RPATH}/${QML_OUTPUT_DIRECTORY}"
      RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${APP_BIN_PATH}/${QML_OUTPUT_DIRECTORY}"
      LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${APP_LIBRARY_PATH}/${QML_OUTPUT_DIRECTORY}"
      ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${APP_LIBRARY_PATH}/${QML_OUTPUT_DIRECTORY}"
  )

  if (library_type STREQUAL "STATIC")
    target_compile_definitions(${_target} PRIVATE QT_STATICPLUGIN)
  endif()

  add_custom_command(
    TARGET ${_target}
    POST_BUILD
    COMMAND
        ${CMAKE_COMMAND} -E copy
        ${_arg_QML_DIR}/qmldir
        $<TARGET_FILE_DIR:${_target}>/qmldir
   )

  install(TARGETS ${_target}
    EXPORT ${APP_CASED_ID}
    RUNTIME DESTINATION "${_DESTINATION}" OPTIONAL
    LIBRARY
      DESTINATION "${APP_LIBRARY_PATH}"
      ${NAMELINK_OPTION}
      OPTIONAL
    OBJECTS
      DESTINATION "${APP_LIBRARY_PATH}"
      COMPONENT Devel EXCLUDE_FROM_ALL
    ARCHIVE
      DESTINATION "${APP_LIBRARY_PATH}"
      COMPONENT Devel EXCLUDE_FROM_ALL
      OPTIONAL
  )

endfunction()



