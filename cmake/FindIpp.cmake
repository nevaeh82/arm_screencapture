if(IPP_INCLUDE_DIR AND IPP_LIBRARIES)
	set(IPP_FIND_QUIETLY TRUE)
endif(IPP_INCLUDE_DIR AND IPP_LIBRARIES)

set(IPP_LIBS
	ipps
	ippac
	ippcc
	ippcore
	ippcv
	ippi
	ipps
	ippvm
	ippch
	ippdc
	ippj
	ippm
	ippr
	ippsc
	ippvc
	ippdi
)

foreach(item ${IPP_LIBS})
	set(lib_var IPP_${item}_LIBRARY)
	find_library(${lib_var} ${item} ${item} PATHS ${PROJECT_BASE_DIR}/redist/ipp/lib)
	list(APPEND IPP_LIBRARIES ${${lib_var}})
endforeach()

find_path(IPP_INCLUDE_DIR ipp.h PATHS ${PROJECT_BASE_DIR}/redist/ipp/include)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(IPP DEFAULT_MSG IPP_LIBRARIES IPP_INCLUDE_DIR)

MARK_AS_ADVANCED(
	IPP_INCLUDE_DIR
	IPP_LIBRARIES
)

