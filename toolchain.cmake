cmake_minimum_required(VERSION 3.18)
include_guard(GLOBAL)

# -------------------------
# Target system
# -------------------------
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Sysroot for the Raspberry Pi
set(TARGET_SYSROOT /home/kylos/rpi-sysroot)
set(TARGET_ARCHITECTURE aarch64-linux-gnu)
set(CMAKE_SYSROOT ${TARGET_SYSROOT})

# -------------------------
# pkg-config setup
# -------------------------
# Tell CMake to use cross-compiled pkg-config automatically
set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/pkgconfig")
set(ENV{PKG_CONFIG_LIBDIR} /usr/lib/pkgconfig:/usr/share/pkgconfig/:${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/pkgconfig:${TARGET_SYSROOT}/usr/lib/pkgconfig)
set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT})

# -------------------------
# Cross-compilers
# -------------------------
set(CMAKE_C_COMPILER /opt/cross-pi-gcc/bin/${TARGET_ARCHITECTURE}-gcc)
set(CMAKE_CXX_COMPILER /opt/cross-pi-gcc/bin/${TARGET_ARCHITECTURE}-g++)

# -------------------------
# C / C++ flags
# -------------------------
set(CMAKE_C_FLAGS "--sysroot=${TARGET_SYSROOT} -O2 -pipe -march=armv8-a -isystem ${TARGET_SYSROOT}/usr/include/${TARGET_ARCHITECTURE}")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}")

# Optional Qt flags
set(QT_COMPILER_FLAGS "-march=armv8-a")
set(QT_COMPILER_FLAGS_RELEASE "-O2 -pipe")
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed -Wl,-rpath-link=${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE} -Wl,-rpath-link=$HOME/qt6/pi/lib")
    
# -------------------------
# Library / include paths
# -------------------------
set(CMAKE_FIND_ROOT_PATH ${TARGET_SYSROOT})
set(CMAKE_BUILD_RPATH ${TARGET_SYSROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)


list(APPEND CMAKE_LIBRARY_PATH ${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE})
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/cmake)

include(CMakeInitializeConfigs)

function(cmake_initialize_per_config_variable _PREFIX _DOCSTRING)
  if (_PREFIX MATCHES "CMAKE_(C|CXX|ASM)_FLAGS")
    set(CMAKE_${CMAKE_MATCH_1}_FLAGS_INIT "${QT_COMPILER_FLAGS}")

    foreach (config DEBUG RELEASE MINSIZEREL RELWITHDEBINFO)
      if (DEFINED QT_COMPILER_FLAGS_${config})
        set(CMAKE_${CMAKE_MATCH_1}_FLAGS_${config}_INIT "${QT_COMPILER_FLAGS_${config}}")
      endif()
    endforeach()
  endif()


  if (_PREFIX MATCHES "CMAKE_(SHARED|MODULE|EXE)_LINKER_FLAGS")
    foreach (config SHARED MODULE EXE)
      set(CMAKE_${config}_LINKER_FLAGS_INIT "${QT_LINKER_FLAGS}")
    endforeach()
  endif()

  _cmake_initialize_per_config_variable(${ARGV})
endfunction()

# -------------------------
# OpenGL / EGL / GBM / XCB libraries
# -------------------------

# Keep the sysroot library paths, but remove explicit inclusion of system headers
set(EGL_LIBRARY   ${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/libEGL.so)
set(OPENGL_opengl_LIBRARY ${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/libOpenGL.so)
set(GLESv2_LIBRARY ${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/libGLESv2.so)
set(gbm_LIBRARY   ${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/libgbm.so)
set(Libdrm_LIBRARY ${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/libdrm.so)
set(XCB_XCB_LIBRARY ${TARGET_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/libxcb.so)
