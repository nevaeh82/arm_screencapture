if(LibSSL_LIBRARIES)
	set(LibSSL_FIND_QUIETLY TRUE)
endif(LibSSL_LIBRARIES)

set(LibSSL_LIBS "libeay32" "ssleay32")

foreach(item ${LibSSL_LIBS})
	find_library(${item}_LibSSL_ITEM
			${item}
			PATHS ${PROJECT_BASE_DIR}/redist/libSSL
			NO_DEFAULT_PATH)
	set(LibSSL_LIBRARIES ${LibSSL_LIBRARIES} ${${item}_LibSSL_ITEM})
endforeach()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibSSL DEFAULT_MSG LibSSL_LIBRARIES)

MARK_AS_ADVANCED(
	LibSSL_LIBRARIES
)
