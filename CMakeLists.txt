cmake_minimum_required(VERSION 3.16.0)

# TODO modify
project(Desktop)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

option(BUILD_STATIC_LIBRARY "Using static build" OFF)
if (BUILD_STATIC_LIBRARY)
  set(_PROJECT_LIBRARY_BUILD_TYPE STATIC CACHE INTERNAL "*** Internal ***" FORCE)
else()
  set(_PROJECT_LIBRARY_BUILD_TYPE SHARED CACHE INTERNAL "*** Internal ***" FORCE)
endif()

get_filename_component(_PROJECT_SOURCE_DIR "." REALPATH CACHE INTERNAL "*** Internal ***" FORCE)
get_filename_component(_PROJECT_3RDPARTY_DIR "3rdParty" REALPATH CACHE INTERNAL "*** Internal ***" FORCE)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "My multi config types" FORCE)

include(vcpkg_config)
include(cmake_helper)
include(project_depends)

feature_summary(INCLUDE_QUIET_PACKAGES WHAT
  PACKAGES_FOUND PACKAGES_NOT_FOUND
  ENABLED_FEATURES DISABLED_FEATURES
)

