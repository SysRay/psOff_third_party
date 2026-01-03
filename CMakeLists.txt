cmake_minimum_required(VERSION 3.24)
include(ExternalProject)

set(ProjectName psOff_third_party)
project(${ProjectName} VERSION 0.0.1)

set(INSTALL_DIR ${CMAKE_BINARY_DIR}/install)
set(BUILDS_DIR ${CMAKE_BINARY_DIR}/builds)

unset(CMAKE_IMPORT_LIBRARY_SUFFIX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing -fno-stack-protector -ffunction-sections")

if(WIN32)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_WIN32_WINNT=0x0A00")
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
endif()

set(CMAKE_C_FLAGS ${CMAKE_CXX_FLAGS})

set(CMAKE_INSTALL_MESSAGE LAZY)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
set(CMAKE_WINDOWS_SYMBOL_VISIBILITY_IN_STATIC_LIBRARIES OFF)

find_package(Vulkan REQUIRED)

ExternalProject_Add(zlib_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/zlib
  BINARY_DIR ${BUILDS_DIR}/zlib
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
)

# SDL3
# APPLY SDL PATCH
ExternalProject_Add(sdl_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/SDL
  BINARY_DIR ${BUILDS_DIR}/sdl
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}

  -DSDL_DIRECTX:BOOL=OFF
  -DSDL_DUMMYVIDEO:BOOL=OFF
  -DSDL_DUMMYCAMERA:BOOL=OFF
  -DSDL_DUMMYAUDIO:BOOL=OFF
  -DSDL_LIBC:BOOL=OFF
  -DSDL_OFFSCREEN:BOOL=OFF
  -DSDL_OPENGL:BOOL=OFF
  -DSDL_OPENGLES:BOOL=OFF
  -DSDL_RENDERER_D3D:BOOL=OFF
  -DSDL_RENDERER_D3D11:BOOL=OFF
  -DSDL_RENDERER_D3D12:BOOL=OFF
  -DSDL_RENDER_GPU:BOOL=OFF
  -DSDL_TESTS:BOOL=OFF
  -DSDL_TESTS_LINK_SHARED:BOOL=OFF
)

if(WIN32)
  set(ZLIB_NAME "zlib.lib")
else()
  set(ZLIB_NAME "libz.so")
endif()

ExternalProject_Add(libpng_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/libpng
  BINARY_DIR ${BUILDS_DIR}/libpng
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}

  -DPNG_SHARED:BOOL=ON
  -DPNG_STATIC:BOOL=OFF
  -DPNG_EXECUTABLES:BOOL=ON
  -DPNG_TOOLS:BOOL=OFF
  -DPNG_TESTS:BOOL=OFF
  -DSKIP_INSTALL_ALL:BOOL=OFF
  -DZLIB_LIBRARY:STRING=${INSTALL_DIR}/lib/${ZLIB_NAME}
  -DZLIB_INCLUDE_DIR:STRING=${INSTALL_DIR}/include
)
ExternalProject_Add_StepDependencies(libpng_project install zlib_project)

install(DIRECTORY "projects/ffmpeg/include/" DESTINATION "${INSTALL_DIR}/include")

install(DIRECTORY "projects/openssl/bin/" DESTINATION "${INSTALL_DIR}/bin")
install(DIRECTORY "projects/openssl/include/" DESTINATION "${INSTALL_DIR}/include")
install(DIRECTORY "projects/openssl/lib/" DESTINATION "${INSTALL_DIR}/lib")

install(DIRECTORY "projects/nlohmann/" DESTINATION ${INSTALL_DIR}/include/nlohmann
  FILES_MATCHING PATTERN "*.hpp"
)

install(DIRECTORY "projects/magic_enum/include/" DESTINATION ${INSTALL_DIR}/include)
install(DIRECTORY "projects/alpaca/include/" DESTINATION ${INSTALL_DIR}/include)
install(DIRECTORY "projects/fixed_containers" DESTINATION "${INSTALL_DIR}/include")
install(DIRECTORY "projects/incbin" DESTINATION "${INSTALL_DIR}/include")
install(DIRECTORY "projects/emhash" DESTINATION "${INSTALL_DIR}/include")
install(DIRECTORY "projects/renderdoc" DESTINATION "${INSTALL_DIR}/include")

ExternalProject_Add(vma_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/VulkanMemoryAllocator
  BINARY_DIR ${BUILDS_DIR}/vma
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
)

install(DIRECTORY "projects/xxhash/include/" DESTINATION ${INSTALL_DIR}/include)

ExternalProject_Add(libzip_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/libzip
  BINARY_DIR ${BUILDS_DIR}/libzip
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}

  -DENABLE_COMMONCRYPTO:BOOL=ON
  -DENABLE_GNUTLS:BOOL=ON
  -DENABLE_MBEDTLS:BOOL=ON
  -DENABLE_OPENSSL:BOOL=OFF
  -DENABLE_FDOPEN:BOOL=OFF
  -DBUILD_TOOLS:BOOL=OFF
  -DBUILD_REGRESS:BOOL=OFF
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_DOC:BOOL=OFF
  -DENABLE_ZSTD:BOOL=OFF
  -DENABLE_LZMA:BOOL=OFF
  -DENABLE_BZIP2:BOOL=OFF
  -DLIBZIP_DO_INSTALL:BOOL=ON
)
ExternalProject_Add_StepDependencies(libzip_project install zlib_project)

set(BOOST_INCLUDE_LIBRARIES "program_options;date_time;interprocess;stacktrace;uuid;beast;signals2;thread;url;asio;dll;serialization;iostreams;process;lockfree;icl")
ExternalProject_Add(boost_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/boost
  BINARY_DIR ${BUILDS_DIR}/boost
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_INSTALL_MESSAGE=NEVER
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}

  -DBoost_USE_STATIC_LIBS=ON
  -DBoost_USE_MULTITHREADED=ON
  -DBUILD_TESTING=OFF
  -DBOOST_INSTALL_LAYOUT=system
  CMAKE_CACHE_ARGS -DBOOST_INCLUDE_LIBRARIES:STRING=${BOOST_INCLUDE_LIBRARIES}
)

ExternalProject_Add(pugixml_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/pugixml
  BINARY_DIR ${BUILDS_DIR}/pugixml
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
)

ExternalProject_Add(zydis_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/zydis
  BINARY_DIR ${BUILDS_DIR}/zydis
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}

  -DZYDIS_BUILD_TOOLS:BOOL=OFF
  -DZYDIS_BUILD_EXAMPLES:BOOL=OFF
)

ExternalProject_Add(zydis_core_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/zydis/dependencies/zycore
  BINARY_DIR ${BUILDS_DIR}/zydis_core
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
)

ExternalProject_Add(tracy_project
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/projects/tracy
  BINARY_DIR ${BUILDS_DIR}/tracy
  CMAKE_ARGS
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
  -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}

  -DTRACY_ENABLE:BOOL=ON
  -DTRACY_STATIC:BOOL=OFF
  -DTRACY_NO_SAMPLING:BOOL=ON,
  -DTRACY_NO_CODE_TRANSFER:BOOL=ON,
  -DTRACY_ONLY_LOCALHOST:BOOL=ON,
  -DTRACY_ON_DEMAND:BOOL=ON,
  -DTRACY_NO_CONTEXT_SWITCH:BOOL=ON,
  -DTRACY_NO_CALLSTACK:BOOL=ON,
  -DTRACY_NO_SYSTEM_TRACING:BOOL=ON,
  -DTRACY_NO_FRAME_IMAGE:BOOL=ON,
  -DTRACY_NO_CRASH_HANDLER:BOOL=ON,
)

install(CODE [[
    set(bin_dir "${CMAKE_BINARY_DIR}/install/bin")
    set(lib_dir "${CMAKE_BINARY_DIR}/install/lib")
    set(config_subdir "RelWithDebInfo")

    foreach(base_dir IN ITEMS "${bin_dir}" "${lib_dir}")
        set(sub_dir "${base_dir}/${config_subdir}")

        if(EXISTS "${sub_dir}")
            file(GLOB sub_contents "${sub_dir}/*")
            foreach(item IN LISTS sub_contents)
                get_filename_component(item_name "${item}" NAME)
                set(target_path "${base_dir}/${item_name}")

                # Move the item to the parent directory (overwrites if exists, but unlikely)
                file(RENAME "${item}" "${target_path}")
                message(STATUS "Moved ${item_name} from ${config_subdir}/ to ${base_dir}")
            endforeach()

            # Clean up the now-empty subdirectory
            file(GLOB remaining "${sub_dir}/*")
            if(NOT remaining)
                file(REMOVE_RECURSE "${sub_dir}")
            endif()
        endif()
    endforeach()
]])

add_library(imgui STATIC
  ${CMAKE_SOURCE_DIR}/projects/imgui/imgui_draw.cpp
  ${CMAKE_SOURCE_DIR}/projects/imgui/imgui_tables.cpp
  ${CMAKE_SOURCE_DIR}/projects/imgui/imgui_widgets.cpp
  ${CMAKE_SOURCE_DIR}/projects/imgui/imgui_demo.cpp
  ${CMAKE_SOURCE_DIR}/projects/imgui/imgui.cpp

  ${CMAKE_SOURCE_DIR}/projects/imgui/backends/imgui_impl_sdl3.cpp
  ${CMAKE_SOURCE_DIR}/projects/imgui/backends/imgui_impl_vulkan.cpp
)

set_target_properties(imgui
  PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY "${INSTALL_DIR}/bin"
  ARCHIVE_OUTPUT_DIRECTORY "${INSTALL_DIR}/lib"
  PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
)

install(FILES
  ${CMAKE_SOURCE_DIR}/projects/imgui/imgui.h
  ${CMAKE_SOURCE_DIR}/projects/imgui/imgui_internal.h
  ${CMAKE_SOURCE_DIR}/projects/imgui/imconfig.h
  ${CMAKE_SOURCE_DIR}/projects/imgui/imstb_rectpack.h
  ${CMAKE_SOURCE_DIR}/projects/imgui/imstb_textedit.h
  ${CMAKE_SOURCE_DIR}/projects/imgui/imstb_truetype.h

  ${CMAKE_SOURCE_DIR}/projects/imgui/backends/imgui_impl_sdl3.h
  ${CMAKE_SOURCE_DIR}/projects/imgui/backends/imgui_impl_vulkan.h

  DESTINATION ${INSTALL_DIR}/include/imgui
)

target_include_directories(imgui PRIVATE
  ${CMAKE_SOURCE_DIR}/projects/imgui/
  ${INSTALL_DIR}/include/
  ${Vulkan_INCLUDE_DIR}
)

add_dependencies(imgui sdl_project)
