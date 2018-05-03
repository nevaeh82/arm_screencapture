set(CROSS_BASE_PATH /mnt/media/projects/lxe/dist/)
set(CROSS_TOOL_NAME AstraLinux-1.4_static)

include(${CROSS_BASE_PATH}${CROSS_TOOL_NAME}/sysroot/usr/share/cmake/${CROSS_TOOL_NAME}.config.cmake)
set(CMAKE_C_COMPILER ${CROSS_BASE_PATH}${CROSS_TOOL_NAME}/bin/x86_64-cross-linux-gnu-gcc-5.2.0)
set(CMAKE_CXX_COMPILER ${CROSS_BASE_PATH}${CROSS_TOOL_NAME}/bin/x86_64-cross-linux-gnu-g++-5.2.0)

SET(SPEC astra)
SET(HOST linux)
