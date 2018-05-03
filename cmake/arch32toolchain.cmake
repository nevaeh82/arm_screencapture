# this one is important
SET(CMAKE_SYSTEM_NAME Linux)

# specify the cross compiler
SET(CMAKE_C_COMPILER /usr/bin/gcc "-m32 -march=geode")
SET(CMAKE_CXX_COMPILER /usr/bin/g++ "-m32 -march=geode")

# where is the target environment
SET(CMAKE_FIND_ROOT_PATH /opt/arch32/rootfs)

# search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)

SET(SPEC linux)
SET(HOST linux)

