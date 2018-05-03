# this one is important
SET(CMAKE_SYSTEM_NAME Linux)

# specify the cross compiler
SET(CMAKE_C_COMPILER /opt/x-tools7h/arm-unknown-linux-gnueabihf/bin/gcc)
SET(CMAKE_CXX_COMPILER /opt/x-tools7h/arm-unknown-linux-gnueabihf/bin/g++)

# where is the target environment
SET(CMAKE_FIND_ROOT_PATH /opt/x-tools7h/arm-unknown-linux-gnueabihf/rootfs3.0)

# search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)

SET(SPEC arm)
SET(HOST linux)
