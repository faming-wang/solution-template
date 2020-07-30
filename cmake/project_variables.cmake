include(FeatureSummary)

set(APP_VERSION "1.0.0")
set(APP_COPYRIGHT_YEAR "2020")

set(APP_DISPLAY_NAME "Desktop")
set(APP_ID "desktop")
set(APP_CASED_ID "Desktop")                        # The cased APP id (no spaces!)
set(_APP_APP_PATH "bin")

if (APPLE)
  set(_APP_TARGET "${APP_DISPLAY_NAME}")
  set(_APP_OUTPUT_PATH "${_APP_APP_PATH}/${_APP_APP_TARGET}.app/Contents")
  set(_APP_PLUGIN_PATH "${_APP_OUTPUT_PATH}/PlugIns")
  set(_APP_LIBRARY_BASE_PATH "Frameworks")
  set(_APP_LIBRARY_PATH "${_APP_OUTPUT_PATH}/Frameworks")
  set(_APP_LIBEXEC_PATH "${_APP_OUTPUT_PATH}/Resources/libexec")
  set(_APP_DATA_PATH "${_APP_OUTPUT_PATH}/Resources")
  set(_APP_DOC_PATH "${_APP_OUTPUT_PATH}/Resources/doc")
  set(_APP_BIN_PATH "${_APP_OUTPUT_PATH}/MacOS")
else ()
  set(_APP_APP_TARGET "${APP_ID}")
  set(_APP_LIBRARY_BASE_PATH "lib")
  set(_APP_LIBRARY_PATH "lib/${APP_ID}")
  set(_APP_PLUGIN_PATH "lib/${APP_ID}/plugins")
  if (WIN32)
    set(_APP_LIBEXEC_PATH "bin")
  else ()
    set(_APP_LIBEXEC_PATH "libexec/${APP_ID}/bin")
  endif ()
  set(_APP_DATA_PATH "share/${APP_ID}")
  set(_APP_DOC_PATH "share/doc/${APP_ID}")
  set(_APP_BIN_PATH "bin")
endif ()

set(APP_APP_PATH "${_APP_APP_PATH}")                    # The target path of the APP application (relative to CMAKE_INSTALL_PREFIX).
set(APP_APP_TARGET "${_APP_APP_TARGET}")                # The APP application name.
set(APP_PLUGIN_PATH "${_APP_PLUGIN_PATH}")              # The APP plugin path (relative to CMAKE_INSTALL_PREFIX).
set(APP_LIBRARY_BASE_PATH "${_APP_LIBRARY_BASE_PATH}")  # The APP library base path (relative to CMAKE_INSTALL_PREFIX).
set(APP_LIBRARY_PATH "${_APP_LIBRARY_PATH}")            # The APP library path (relative to CMAKE_INSTALL_PREFIX).
set(APP_LIBEXEC_PATH "${_APP_LIBEXEC_PATH}")            # The APP libexec path (relative to CMAKE_INSTALL_PREFIX).
set(APP_DATA_PATH "${_APP_DATA_PATH}")                  # The APP data path (relative to CMAKE_INSTALL_PREFIX).
set(APP_DOC_PATH "${_APP_DOC_PATH}")                    # The APP documentation path (relative to CMAKE_INSTALL_PREFIX).
set(APP_BIN_PATH "${_APP_BIN_PATH}")                    # The APP bin path (relative to CMAKE_INSTALL_PREFIX).

file(RELATIVE_PATH RELATIVE_PLUGIN_PATH "/${APP_BIN_PATH}" "/${APP_PLUGIN_PATH}")
file(RELATIVE_PATH RELATIVE_LIBEXEC_PATH "/${APP_BIN_PATH}" "/${APP_LIBEXEC_PATH}")
file(RELATIVE_PATH RELATIVE_DATA_PATH "/${APP_BIN_PATH}" "/${APP_DATA_PATH}")
file(RELATIVE_PATH RELATIVE_DOC_PATH "/${APP_BIN_PATH}" "/${APP_DOC_PATH}")

file(RELATIVE_PATH _PLUGIN_TO_LIB "/${APP_PLUGIN_PATH}" "/${APP_LIBRARY_PATH}")

if (APPLE)
  set(_RPATH_BASE "@executable_path")
  set(_LIB_RPATH "@loader_path")
  set(_PLUGIN_RPATH "@loader_path;@loader_path/${_PLUGIN_TO_LIB}")
elseif (WIN32)
  set(_RPATH_BASE "")
  set(_LIB_RPATH "")
  set(_PLUGIN_RPATH "")
else()
  set(_RPATH_BASE "\$ORIGIN")
  set(_LIB_RPATH "\$ORIGIN")
  set(_PLUGIN_RPATH "\$ORIGIN;\$ORIGIN/${_PLUGIN_TO_LIB}")
endif ()

set(APPEND APP_DEFAULT_DEFINES
  RELATIVE_PLUGIN_PATH="${RELATIVE_PLUGIN_PATH}"
  RELATIVE_LIBEXEC_PATH="${RELATIVE_LIBEXEC_PATH}"
  RELATIVE_DATA_PATH="${RELATIVE_DATA_PATH}"
  RELATIVE_DOC_PATH="${RELATIVE_DOC_PATH}"
)
