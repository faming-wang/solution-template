# zlib
add_library(zlib_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::zlib ALIAS zlib_depends)
find_package(ZLIB REQUIRED)
target_link_libraries(zlib_depends INTERFACE ZLIB::ZLIB)

# lz4
add_library(lz4_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::lz4 ALIAS lz4_depends)
find_package(lz4 CONFIG REQUIRED)
target_link_libraries(lz4_depends INTERFACE lz4::lz4)

# LibLZMA
add_library(lzma_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::lzma ALIAS lzma_depends)
find_package(LibLZMA CONFIG REQUIRED)
target_link_libraries(lzma_depends INTERFACE LibLZMA::LibLZMA)

# BZip2
add_library(bzip2_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::bzip2 ALIAS bzip2_depends)
find_package(BZip2 REQUIRED)
target_link_libraries(bzip2_depends INTERFACE BZip2::BZip2)

# minizip
add_library(minizip_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::minizip ALIAS minizip_depends)
find_package(minizip CONFIG REQUIRED)
target_link_libraries(minizip_depends INTERFACE minizip::minizip)

# spdlog
add_library(spdlog_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::spdlog ALIAS spdlog_depends)
find_package(spdlog CONFIG REQUIRED)
target_link_libraries(spdlog_depends INTERFACE spdlog::spdlog spdlog::spdlog_header_only)

# libqrencode
add_library(qrencode_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::qrencode ALIAS qrencode_depends)
find_path(QRENCODE_INCLUDE_DIR NAMES qrencode.h)
find_library(QRENCODE_LIBRARY_RELEASE qrencode)
find_library(QRENCODE_LIBRARY_DEBUG qrencoded)
set(QRENCODE_LIBRARIES optimized ${QRENCODE_LIBRARY_RELEASE} debug ${QRENCODE_LIBRARY_DEBUG})
target_include_directories(qrencode_depends INTERFACE ${QRENCODE_INCLUDE_DIR})
target_link_libraries(qrencode_depends INTERFACE ${QRENCODE_LIBRARIES})

# breakpad
add_library(breakpad_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::breakpad ALIAS breakpad_depends)
find_package(unofficial-breakpad CONFIG REQUIRED)
target_link_libraries(breakpad_depends INTERFACE
  unofficial::breakpad::libbreakpad
  unofficial::breakpad::libbreakpad_client
)

# gls
add_library(gsl_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::gsl ALIAS gsl_depends)
find_package(Microsoft.GSL CONFIG REQUIRED)
target_link_libraries(gsl_depends INTERFACE Microsoft.GSL::GSL)

# range-v3
add_library(ranges_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::ranges ALIAS ranges_depends)
find_package(range-v3 CONFIG REQUIRED)
target_link_libraries(ranges_depends INTERFACE range-v3 range-v3-meta range-v3::meta range-v3-concepts)
if (WIN32)
  target_compile_options(ranges_depends INTERFACE
    /permissive-
    /std:c++17
    #/Zc:preprocessor # need for range-v3 see https://github.com/ericniebler/range-v3#supported-compilers
    #/wd5105 # needed for `/experimental:preprocessor`, suppressing C5105 "macro expansion producing 'defined' has undefined behavior"
  )
else()
  target_compile_features(ranges_depends INTERFACE cxx_std_17)
endif()

# variant
add_library(variant_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::variant ALIAS variant_depends)
find_package(mpark_variant CONFIG REQUIRED)
target_link_libraries(variant_depends INTERFACE mpark_variant)

# tl-expected
add_library(tl_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::tl ALIAS tl_depends)
find_package(tl-expected CONFIG REQUIRED)
target_link_libraries(tl_depends INTERFACE tl::expected)

# OpenAL
add_library(openal_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::openal ALIAS openal_depends)
find_package(OpenAL CONFIG)
if (NOT OpenAL_DIR STREQUAL "OpenAL_DIR-NOTFOUND")
  target_link_libraries(openal_depends INTERFACE OpenAL::OpenAL)
  target_compile_definitions(openal_depends INTERFACE AL_ALEXT_PROTOTYPES)
endif()

# OpenCL
add_library(opencl_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::opencl ALIAS opencl_depends)
find_package(OpenCL REQUIRED)
target_link_libraries(opencl_depends INTERFACE OpenCL::OpenCL)

# OpenSSL
add_library(openssl_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::openssl ALIAS openssl_depends)
find_package(OpenSSL REQUIRED)
target_link_libraries(openssl_depends INTERFACE OpenSSL::SSL OpenSSL::Crypto)

# FFmpeg
add_library(ffmpeg_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::ffmpeg ALIAS ffmpeg_depends)
find_package(ffmpeg REQUIRED)
target_include_directories(ffmpeg_depends INTERFACE ${FFMPEG_INCLUDE_DIRS})
target_link_libraries(ffmpeg_depends INTERFACE ${FFMPEG_LIBRARIES})

# wil
add_library(wil_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::wil ALIAS wil_depends)
if(WIN32)
  find_path(WIL_INCLUDE_DIR NAMES wil)
  target_include_directories(wil_depends INTERFACE ${WIL_INCLUDE_DIR})
endif()

# xxhash
add_library(xxhash_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::xxhash ALIAS xxhash_depends)
find_path(XXHASH_INCLUDE_DIR NAMES xxhash.h)
find_library(XXHASH_LIBRARY_RELEASE xxhash)
find_library(XXHASH_LIBRARY_DEBUG xxhash)
set(XXHASH_LIBRARIES optimized ${XXHASH_LIBRARY_RELEASE} debug ${XXHASH_LIBRARY_DEBUG})
target_include_directories(xxhash_depends INTERFACE ${XXHASH_INCLUDE_DIR})
target_link_libraries(xxhash_depends INTERFACE ${XXHASH_LIBRARIES})

# protobuf
add_library(protobuf_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::protobuf ALIAS protobuf_depends)
find_package(protobuf CONFIG REQUIRED)
target_link_libraries(protobuf_depends INTERFACE protobuf::libprotoc protobuf::libprotobuf protobuf::libprotobuf-lite)

# rxcpp
add_library(rxcpp_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::rxcpp ALIAS rxcpp_depends)
find_package(rxcpp CONFIG REQUIRED)
target_link_libraries(rxcpp_depends INTERFACE rxcpp)

# abseil
add_library(abseil_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::abseil ALIAS abseil_depends)

find_package(absl CONFIG REQUIRED)
# Note: 118 target(s) were omitted.
target_link_libraries(abseil_depends INTERFACE absl::any absl::base absl::bits absl::city)

# zxing
add_library(zxing_depends INTERFACE IMPORTED GLOBAL)
add_library(third_party::zxing ALIAS zxing_depends)
find_package(zxing CONFIG)
target_link_libraries(zxing_depends INTERFACE zxing::libzxing)

