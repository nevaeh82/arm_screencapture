if(ENET_INCLUDE_DIR AND ENET_LIBRARY)
	set(ENET_FIND_QUIETLY TRUE)
endif(ENET_INCLUDE_DIR AND ENET_LIBRARY)

find_library(ENET_LIBRARY enet
			PATHS ${PROJECT_BASE_DIR}/redist/enet/lib_${SPEC})

find_path(ENET_INCLUDE_DIR enet/enet.h
		PATHS ${PROJECT_BASE_DIR}/redist/enet/include)

if(WIN32)
set(ENET_LIBRARY ${ENET_LIBRARY} -lws2_32)
endif()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Enet DEFAULT_MSG ENET_LIBRARY ENET_INCLUDE_DIR)

MARK_AS_ADVANCED(
	ENET_INCLUDE_DIR
	ENET_LIBRARY
)
