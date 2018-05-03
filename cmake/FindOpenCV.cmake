if(OPENCV_INCLUDE_DIR AND OPENCV_LIBRARIES)
	set(OPENCV_FIND_QUIETLY TRUE)
endif(OPENCV_INCLUDE_DIR AND OPENCV_LIBRARIES)

set(OPENCV_LIBS "opencv_calib3d" "opencv_core" "opencv_features2d" "opencv_flann" "opencv_highgui" "opencv_imgproc")
set(OPENCV_LIBS_3_1_X "opencv_imgcodecs")

set(OPENCV_LIB_EX "/")

if (MSVC)
	if (CMAKE_BUILD_TYPEUP STREQUAL DEBUG AND WIN32)
		set(OPENCV_LIB_EX "/Debug")
		set(OPENCV_LIB_VER "330d")
	else()
		set(OPENCV_LIB_EX "/Release")
		set(OPENCV_LIB_VER "330")
	endif()
else()
	set(OPENCV_LIB_VER "2413")
endif(MSVC)

foreach(item ${OPENCV_LIBS})
	find_library(${item}_OPENCV_ITEM
			${item} lib${item} ${item}${OPENCV_LIB_VER} lib${item}${OPENCV_LIB_VER}
			PATHS ${PROJECT_BASE_DIR}/redist/OpenCV/${FULL_QT_VERSION}/lib_${SPEC}${OPENCV_LIB_EX})
	set(OPENCV_LIBRARIES ${OPENCV_LIBRARIES} ${${item}_OPENCV_ITEM})
endforeach()

foreach(item ${OPENCV_LIBS_3_1_X})
	find_library(${item}_OPENCV_ITEM
			${item} lib${item} ${item}${OPENCV_LIB_VER} lib${item}${OPENCV_LIB_VER}
			PATHS ${PROJECT_BASE_DIR}/redist/OpenCV/${FULL_QT_VERSION}/lib_${SPEC}${OPENCV_LIB_EX})
	if (${item}_OPENCV_ITEM)
		set(OPENCV_LIBRARIES ${OPENCV_LIBRARIES} ${${item}_OPENCV_ITEM})
	endif()
endforeach()

find_path(OPENCV_INCLUDE_DIR
	opencv
	PATHS ${PROJECT_BASE_DIR}/redist/OpenCV/${FULL_QT_VERSION}/include_${SPEC})



INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OPENCV DEFAULT_MSG OPENCV_LIBRARIES OPENCV_INCLUDE_DIR)

MARK_AS_ADVANCED(
	OPENCV_INCLUDE_DIR
	OPENCV_LIBRARIES
)
