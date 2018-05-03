if(Libgomp_LIBRARIES)
	set(Libgomp_FIND_QUIETLY TRUE)
endif(Libgomp_LIBRARIES)

set(Libgomp_LIBS "libgomp-1")

foreach(item ${Libgomp_LIBS})
	find_library(${item}_Libgomp_ITEM
			${item}
			PATHS ${PROJECT_BASE_DIR}/redist/libgomp-1
			NO_DEFAULT_PATH)
	set(Libgomp_LIBRARIES ${Libgomp_LIBRARIES} ${${item}_Libgomp_ITEM})
endforeach()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Libgomp DEFAULT_MSG Libgomp_LIBRARIES)

MARK_AS_ADVANCED(
	Libgomp_LIBRARIES
)
