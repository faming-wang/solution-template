set(_qt_packages
  Core
  Svg
  Gui
  Xml
  OpenGL
  Widgets
  Network
  NetworkAuth
  WebSockets
  Concurrent
  Multimedia
  MultimediaWidgets
)

list(APPEND _qt_packages
  Qml
  QmlModels
  QmlWorkerScript
)
list(APPEND _qt_packages
  Quick
  QuickShapes
  QuickWidgets
  QuickParticles
  QuickControls2
  QuickTemplates2
  MultimediaQuick
)

if(WIN32)
  list(APPEND _qt_packages WinExtras)
elseif(APPLE)
  list(APPEND _qt_packages MacExtras)
elseif(LINUX)
endif()

find_package(Qt5 COMPONENTS ${_qt_packages} REQUIRED)

foreach(pkg IN LISTS _qt_packages)
  list(APPEND _qt_link_depends "Qt5::${pkg}" "Qt5::${pkg}Private")
endforeach()

add_library(qt_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::qt ALIAS qt_depends)

target_link_libraries(qt_depends INTERFACE ${_qt_link_depends})

set_property(GLOBAL PROPERTY AUTOGEN_SOURCE_GROUP "(generate)")
set_property(GLOBAL PROPERTY AUTOGEN_TARGETS_FOLDER "(generate)")

add_executable(qt_tools::moc IMPORTED Qt5::moc)
add_executable(qt_tools::rcc IMPORTED Qt5::rcc)
add_executable(qt_tools::uic IMPORTED Qt5::uic)
add_executable(qt_tools::qmake IMPORTED Qt5::qmake)

find_package(Qt5LinguistTools REQUIRED)
add_executable(qt_tools::lupdate IMPORTED Qt5::lupdate)
add_executable(qt_tools::lconvert IMPORTED Qt5::lconvert)
add_executable(qt_tools::lrelease IMPORTED Qt5::lrelease)

