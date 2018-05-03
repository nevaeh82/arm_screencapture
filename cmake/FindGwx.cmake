if(GWX_INCLUDE_DIR AND GWX_LIBRARY)
  set(GWX_FIND_QUIETLY TRUE)
endif(GWX_INCLUDE_DIR AND GWX_LIBRARY)

find_library(GWX_LIBRARY Gwx PATHS ${PROJECT_BASE_DIR}/redist/Gwx/bin)

set(GWX_INCLUDE_DIR ${PROJECT_BINARY_DIR}/redist/Gwx/include)

# Generate GWX include
add_custom_command(OUTPUT ${GWX_INCLUDE_DIR}/gwxlib.hpp
                   COMMAND dumpcpp Ingit.GWControl
                   COMMENT "Generate a C++ namespace for Gwx library")

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Gwx DEFAULT_MSG GWX_LIBRARY GWX_INCLUDE_DIR)

MARK_AS_ADVANCED(
  GWX_INCLUDE_DIR
  GWX_LIBRARY
)
