if(JSON_CPP_INCLUDE_DIR AND JSON_CPP_LIBRARY)
	set (JSON_CPP_FIND_QUIETLY TRUE)
endif(JSON_CPP_INCLUDE_DIR AND JSON_CPP_LIBRARY)

find_library(JSON_CPP_LIBRARY jsoncpp
	NAME libjson_mingw_libmt
	PATHS ${PROJECT_BASE_DIR}/redist/jsoncpp/4.7.4/lib_${SPEC})

find_path(JSON_CPP_INCLUDE_DIR json/json.h
	PATH_SUFFIXES jsoncpp
	PATHS ${PROJECT_BASE_DIR}/redist/jsoncpp/4.7.4/include)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Jsoncpp DEFAULT_MSG JSON_CPP_LIBRARY JSON_CPP_INCLUDE_DIR)

MARK_AS_ADVANCED(
	JSON_CPP_LIBRARY
	JSON_CPP_INCLUDE_DIR
)
