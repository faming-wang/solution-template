##############################################
# Setup path handling
include(FeatureSummary)

set (CMAKE_DEBUG_POSTFIX d)
set (CMAKE_CXX_STANDARD_REQUIRED ON)

macro(set_solution_configure _solution_name)
  cmake_parse_arguments(_configure "" ""
      "${multiValueArgs}" 
      ${ARGN}
  )
  set(_solution_name "${_solution_name}")
  set(_solution_app_path "bin")
  if (APPLE)
    set(_solution_app_target "${_solution_name}")
    set(_solution_output_path "${_solution_app_path}/${_solution_app_target}.app/Contents")
    set(_solution_plugin_path "${_solution_output_path}/PlugIns")
    set(_solution_library_base_path "Frameworks")
    set(_solution_library_path "${_solution_output_path}/Frameworks")
    set(_solution_libexec_path "${_solution_output_path}/Resources")
    set(_solution_data_path "${_solution_output_path}/Resources")
    set(_solution_doc_path "${_solution_output_path}/Resources/doc")
    set(_solution_bin_path "${_solution_output_path}/MacOS")
  else ()
    set(_solution_app_target "${_solution_name}")
    set(_solution_library_base_path "lib")
    set(_solution_library_path "lib/${_solution_name}")
    set(_solution_plugin_path "lib/${_solution_name}/plugins")
    if (WIN32)
      set(_solution_libexec_path "bin")
    else ()
      set(_solution_libexec_path "libexec/${_solution_name}/bin")
    endif ()
    set(_solution_data_path "share/${_solution_name}")
    set(_solution_doc_path "share/doc/${_solution_name}")
    set(_solution_bin_path "bin")
  endif ()
  # The target path of the solution application (relative to CMAKE_INSTALL_PREFIX).
  set(solution_app_path "${_solution_app_path}") 
  # The solution application name.
  set(solution_app_target "${_solution_app_target}") 
  # The solution plugin path (relative to CMAKE_INSTALL_PREFIX).
  set(solution_plugin_path "${_solution_plugin_path}") 
  # The solution library base path (relative to CMAKE_INSTALL_PREFIX).
  set(solution_library_base_path "${_solution_library_base_path}") 
  # The solution library path (relative to CMAKE_INSTALL_PREFIX).
  set(solution_library_path "${_solution_library_path}") 
  # The solution libexec path (relative to CMAKE_INSTALL_PREFIX).
  set(solution_libexec_path "${_solution_libexec_path}") 
  # The solution data path (relative to CMAKE_INSTALL_PREFIX).
  set(solution_data_path "${_solution_data_path}") 
  # The solution documentation path (relative to CMAKE_INSTALL_PREFIX).
  set(solution_doc_path "${_solution_doc_path}") 
  # The solution bin path (relative to CMAKE_INSTALL_PREFIX).
  set(solution_bin_path "${_solution_bin_path}") 
  
  file(RELATIVE_PATH relative_plugin_path "/${solution_bin_path}" "/${solution_plugin_path}")
  file(RELATIVE_PATH relative_libexec_path "/${solution_bin_path}" "/${solution_libexec_path}")
  file(RELATIVE_PATH relative_data_path "/${solution_bin_path}" "/${solution_data_path}")
  file(RELATIVE_PATH relative_doc_path "/${solution_bin_path}" "/${solution_doc_path}")
  
  list(APPEND _default_defines
    relative_plugin_path="${relative_plugin_path}"
    relative_libexec_path="${relative_libexec_path}"
    relative_data_path="${relative_data_path}"
    relative_doc_path="${relative_doc_path}"
  )

  file(RELATIVE_PATH _plugin_to_lib "/${solution_plugin_path}" "/${solution_library_path}")

  if (APPLE)
    set(_relative_path_base "@executable_path")
    set(_lib_relative_path "@loader_path")
    set(_plugin_relative_path "@loader_path;@loader_path/${_plugin_to_lib}")
  elseif (WIN32)
    set(_relative_path_base "")
    set(_lib_relative_path "")
    set(_plugin_relative_path "")
  else()
    set(_relative_path_base "\$ORIGIN")
    set(_lib_relative_path "\$ORIGIN")
    set(_plugin_relative_path "\$ORIGIN;\$ORIGIN/${_plugin_to_lib}")
  endif ()
endmacro()
##############################################
# target_public_headers
function(target_public_headers _target _sources)
  foreach(_source IN LISTS _sources)
    if (_source MATCHES "\.h$|\.hpp$")

      if (NOT IS_ABSOLUTE ${_source})
        set(_source "${CMAKE_CURRENT_SOURCE_DIR}/${_source}")
      endif()

      get_filename_component(source_dir ${_source} DIRECTORY)
      file(RELATIVE_PATH include_dir_relative_path ${PROJECT_SOURCE_DIR} ${source_dir})

      install(
        FILES ${_source}
        DESTINATION "include/${include_dir_relative_path}"
        COMPONENT Devel EXCLUDE_FROM_ALL
      )
    endif()
  endforeach()
endfunction()
##############################################
# target_public_includes
function(target_public_includes _target _includes)
  foreach(_include IN LISTS _includes)
    if (NOT IS_ABSOLUTE ${_include})
      set(_include "${CMAKE_CURRENT_SOURCE_DIR}/${_include}")
    endif()
    target_include_directories(${_target} PUBLIC $<BUILD_INTERFACE:${_include}>)
  endforeach()
endfunction()
##############################################
# libraries_spliter
function(libraries_spliter _libraries standard_libs object_libs object_lib_objects)
  if (CMAKE_VERSION VERSION_LESS 3.14)
    foreach(_lib IN LISTS _libraries)
      if (TARGET ${_lib})
        get_target_property(_lib_type ${_lib} TYPE)
        if (_lib_type STREQUAL "OBJECT_LIBRARY")
          list(APPEND _object_libs ${_lib})
          list(APPEND _object_libs_objects $<TARGET_OBJECTS:${_lib}>)
        else()
          list(APPEND _standard_libs ${_lib})
        endif()
      else()
        list(APPEND _standard_libs ${lib})
      endif()
      set(${standard_libs} ${_standard_libs} PARENT_SCOPE)
      set(${object_libs} ${_object_libs} PARENT_SCOPE)
      set(${object_lib_objects} ${_object_libs_objects} PARENT_SCOPE)
    endforeach()
  else()
    set(${standard_libs} ${_libraries} PARENT_SCOPE)
    unset(${object_libs} PARENT_SCOPE)
    unset(${object_lib_objects} PARENT_SCOPE)
  endif()
endfunction()
##############################################
# target_depends
function(target_depends _target)
  cmake_parse_arguments(_arg "" "" "PRIVATE;PUBLIC" ${ARGN})
  if (${_arg_UNPARSED_ARGUMENTS})
    message(FATAL_ERROR "target_depends had unparsed arguments")
  endif()
  libraries_spliter("${_arg_PRIVATE}" _depends _object_lib_depends _object_lib_depends_objects)
  libraries_spliter("${_arg_PUBLIC}" _public_depends _object_public_depends _object_public_depends_objects)

  target_sources(${_target} PRIVATE ${_object_lib_depends_objects} ${_object_public_depends_objects})
  get_target_property(_target_type ${_target} TYPE)
  
  if (NOT _target_type STREQUAL "OBJECT_LIBRARY")
    target_link_libraries(${_target} PRIVATE ${_depends} PUBLIC ${_public_depends})
  else()
    list(APPEND _object_lib_depends ${_depends})
    list(APPEND _object_public_depends ${_public_depends})
  endif()

  foreach(_obj_lib IN LISTS _object_lib_depends)
    target_compile_definitions(${_target} PRIVATE $<TARGET_PROPERTY:${_obj_lib},INTERFACE_COMPILE_DEFINITIONS>)
    target_include_directories(${_target} PRIVATE $<TARGET_PROPERTY:${_obj_lib},INTERFACE_INCLUDE_DIRECTORIES>)
  endforeach()
  foreach(_obj_lib IN LISTS _object_public_depends)
    target_compile_definitions(${_target} PUBLIC $<TARGET_PROPERTY:${_obj_lib},INTERFACE_COMPILE_DEFINITIONS>)
    target_include_directories(${_target} PUBLIC $<TARGET_PROPERTY:${_obj_lib},INTERFACE_INCLUDE_DIRECTORIES>)
  endforeach()
endfunction()
##############################################
# target_extend
function(target_extend _target)
  cmake_parse_arguments(_arg
    ""
    "SOURCES_PREFIX"
    "SOURCES;
     CONDITION;
     DEPENDS;
     PUBLIC_DEPENDS;
     DEFINES;
     PUBLIC_DEFINES;
     INCLUDES;
     PUBLIC_INCLUDES"
    ${ARGN}
  )
  if (${_arg_UNPARSED_ARGUMENTS})
    message(FATAL_ERROR "target_extend had unparsed arguments")
  endif()

  # CONDITION;
  if (NOT _arg_CONDITION)
    set(_arg_CONDITION ON)
  endif()
  if (NOT (${_arg_CONDITION}))
    return()
  endif()

  # DEPENDS;PUBLIC_DEPENDS;
  target_depends(${_target}
    PRIVATE ${_arg_DEPENDS}
    PUBLIC ${_arg_PUBLIC_DEPENDS}
  )
  # DEFINES;PUBLIC_DEFINES;
  target_compile_definitions(${_target}
    PRIVATE ${_arg_DEFINES}
    PUBLIC ${_arg_PUBLIC_DEFINES}
  )
  # INCLUDES;
  target_include_directories(${_target} PRIVATE ${_arg_INCLUDES})
  # PUBLIC_INCLUDES"
  target_public_includes(${_target} "${_arg_PUBLIC_INCLUDES}")

  # SOURCES;SOURCES_PREFIX;
  if (_arg_SOURCES_PREFIX)
    foreach(source IN LISTS _arg_SOURCES)
      list(APPEND prefixed_sources "${_arg_SOURCES_PREFIX}/${source}")
    endforeach()

    if (NOT IS_ABSOLUTE ${_arg_SOURCES_PREFIX})
      set(_arg_SOURCES_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/${_arg_SOURCES_PREFIX}")
    endif()
    target_include_directories(${_target} PUBLIC $<BUILD_INTERFACE:${_arg_SOURCES_PREFIX}>)

    set(_arg_SOURCES ${prefixed_sources})
  endif()
  target_sources(${_target} PRIVATE ${_arg_SOURCES})
  target_public_headers(${_target} "${_arg_SOURCES}")
endfunction()
##############################################
# add_library_ex
function(add_library_ex _lib_name)
  cmake_parse_arguments(_arg 
    "STATIC;OBJECT" 
    "VERSION"
    "SOURCES;
     DEFINES;
     PUBLIC_DEFINES;
     INCLUDES;
     PUBLIC_INCLUDES;
     DEPENDS;
     PUBLIC_DEPENDS;
     PROPERTIES"
    ${ARGN}
  )
  if (${_arg_UNPARSED_ARGUMENTS})
    message(FATAL_ERROR "add_qtc_library had unparsed arguments")
  endif()

  # "STATIC;OBJECT"
  set(_library_type SHARED)
  if (_arg_STATIC)
    set(_library_type STATIC)
  endif()
  if (_arg_OBJECT)
    set(_library_type OBJECT)
  endif()

  # SOURCES;
  add_library(${_lib_name} ${_library_type} EXCLUDE_FROM_ALL ${_arg_SOURCES})
  add_library(${_solution_name}::${_lib_name} ALIAS ${_lib_name})
  target_public_headers(${_lib_name} "${_arg_SOURCES}")

  if (${_lib_name} MATCHES "^[^0-9]+")
    string(TOUPPER "${_lib_name}_LIBRARY" EXPORT_SYMBOL)
  endif()

  # INCLUDES;
  file(RELATIVE_PATH _include_relative_path ${PROJECT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
  target_include_directories(${_lib_name}
    PRIVATE ${_arg_INCLUDES}
    PUBLIC
      "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
      "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>"
      "$<INSTALL_INTERFACE:include/${_include_relative_path}>"
      "$<INSTALL_INTERFACE:include/${_include_relative_path}/..>"
  )

  # PUBLIC_INCLUDES;
  target_public_includes(${_lib_name} "${_arg_PUBLIC_INCLUDES}")

  # DEFINES; PUBLIC_DEFINES;
  target_compile_definitions(${_lib_name}
    PRIVATE ${EXPORT_SYMBOL} ${_arg_DEFINES} ${_default_defines} ${_test_defines}
    PUBLIC ${_arg_PUBLIC_DEFINES}
  )

  # DEPENDS; PUBLIC_DEPENDS;
  target_depends(${_lib_name}
    PRIVATE ${_arg_DEPENDS} ${_test_depends}
    PUBLIC ${_arg_PUBLIC_DEPENDS}
  )

  # PROPERTIES;
  set_target_properties(${_lib_name} PROPERTIES
    SOURCES_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
    VERSION "${_arg_VERSION}"
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    BUILD_RPATH "${_lib_relative_path}"
    INSTALL_RPATH "${_lib_relative_path}"
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${solution_bin_path}"
    LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${solution_library_path}"
    ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${solution_library_path}"
    ${_arg_PROPERTIES}
  )

  ### install
  install(TARGETS ${_lib_name}
    EXPORT ${_solution_name}
    RUNTIME DESTINATION "${solution_bin_path}"
    LIBRARY
      DESTINATION "${solution_library_path}"
      ${NAMELINK_OPTION}
    OBJECTS
      DESTINATION "${solution_library_path}"
      COMPONENT Devel EXCLUDE_FROM_ALL
    ARCHIVE
      DESTINATION "${solution_library_path}"
      COMPONENT Devel EXCLUDE_FROM_ALL
  )

  if (NAMELINK_OPTION)
    install(TARGETS ${name}
      LIBRARY
        DESTINATION "${solution_library_path}"
        NAMELINK_ONLY
        COMPONENT Devel EXCLUDE_FROM_ALL
    )
  endif()
endfunction()
##############################################
# add_executable_ex
function(add_executable_ex _exec_name)
  cmake_parse_arguments(_arg 
    "SKIP_INSTALL" 
    "DESTINATION" 
    "DEFINES;
     DEPENDS;
     INCLUDES;
     SOURCES;
     PROPERTIES" 
    ${ARGN}
  )
  if ($_arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "add_executable_ex had unparsed arguments!")
  endif()

  #string(TOUPPER "BUILD_EXECUTABLE_${name}" _build_executable_var)
  #set(_build_executable_default "ON")
  #if (DEFINED ENV{QTC_${_build_executable_var}})
  #  set(_build_executable_default "$ENV{QTC_${_build_executable_var}}")
  #endif()
  #set(${_build_executable_var} "${_build_executable_default}" CACHE BOOL "Build executable ${name}.")
  #
  #if (NOT ${_build_executable_var})
  #  return()
  #endif()

  # DESTINATION;
  set(_destination "${solution_libexec_path}")
  if (_arg_DESTINATION)
    set(_destination "${_arg_DESTINATION}")
  endif()
  set(_executable_path "${_destination}")

  if (APPLE)
    # path of executable might be inside app bundle instead of DESTINATION directly
    cmake_parse_arguments(_prop "" "MACOSX_BUNDLE;OUTPUT_NAME" "" "${_arg_PROPERTIES}")
    if (_prop_MACOSX_BUNDLE)
      set(
      "${_exec_name}")
      if (_prop_OUTPUT_NAME)
        set(_bundle_name "${_prop_OUTPUT_NAME}")
      endif()
      set(_executable_path "${_destination}/${_bundle_name}.app/Contents/MacOS")
    endif()
  endif()

  file(RELATIVE_PATH _relative_lib_path "/${_executable_path}" "/${solution_library_path}")
  # SOURCES;
  add_executable("${_exec_name}" ${_arg_SOURCES})
  # INCLUDES;
  target_include_directories("${_exec_name}" PRIVATE "${CMAKE_BINARY_DIR}/src" ${_arg_INCLUDES})
  # DEFINES;
  target_compile_definitions("${_exec_name}" PRIVATE ${_arg_DEFINES} ${_test_defines} ${_default_defines})
  # DEPENDS;
  target_link_libraries("${_exec_name}" PRIVATE ${_arg_DEPENDS} ${_test_depends})
  # PROPERTIES
  set_target_properties("${_exec_name}" PROPERTIES
    BUILD_RPATH "${_relative_path_base}/${_relative_lib_path}"
    INSTALL_RPATH "${_relative_path_base}/${_relative_lib_path}"
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${_destination}"
    ${_arg_PROPERTIES}
  )

  if (NOT _arg_SKIP_INSTALL)
    install(TARGETS ${_exec_name} DESTINATION "${_destination}")
  endif()   
endfunction()
##############################################
# fixed_test_environment 
function(fixed_test_environment _test_name)
  if (WIN32)                                       
    list(APPEND _env_path $ENV{PATH})         
    list(APPEND _env_path ${CMAKE_BINARY_DIR}/${solution_plugin_path})
    list(APPEND _env_path ${CMAKE_BINARY_DIR}/${solution_bin_path})
    list(APPEND _env_path $<TARGET_FILE_DIR:Qt5::Test>)
    if (TARGET libclang)
        list(APPEND _env_path $<TARGET_FILE_DIR:libclang>)
    endif()

    string(REPLACE "/" "\\" _env_path "${_env_path}")
    string(REPLACE ";" "\\;" _env_path "${_env_path}")

    set_tests_properties(${_test_name} PROPERTIES ENVIRONMENT "PATH=${_env_path}")
  endif()
endfunction()
##############################################
# add_google_test
function(add_google_test _test_name)
  get_target_property(test_sources ${_test_name} SOURCES)

  include(GoogleTest)
  gtest_add_tests(TARGET ${_test_name} SOURCES ${test_sources} TEST_LIST test_list)

  foreach(_test IN LISTS test_list)
    fixed_test_environment(${_test})
  endforeach()
endfunction()
##############################################
