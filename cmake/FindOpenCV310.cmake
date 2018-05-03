if(OPENCV_INCLUDE_DIR AND OPENCV_LIBRARIES)
	set(OPENCV_FIND_QUIETLY TRUE)
endif(OPENCV_INCLUDE_DIR AND OPENCV_LIBRARIES)

set(OPENCV_LIBS "opencv_calib3d" "opencv_core" "opencv_features2d" "opencv_flann" "opencv_highgui" "opencv_imgproc" "opencv_video" "opencv_videoio")
set(OPENCV_LIBS_3_1_X "opencv_imgcodecs")

set(OPENCV_LIB_VER "310")

find_path(OPENCV_INCLUDE_DIR
	opencv
	PATHS ${PROJECT_BASE_DIR}/redist/OpenCV/sources/include)

foreach(item ${OPENCV_LIBS})
	find_library(${item}_OPENCV_ITEM
			${item} lib${item} ${item}${OPENCV_LIB_VER} lib${item}${OPENCV_LIB_VER}
			PATHS ${PROJECT_BASE_DIR}/redist/OpenCV/lib_${SPEC})
	set(OPENCV_LIBRARIES ${OPENCV_LIBRARIES} ${${item}_OPENCV_ITEM})
	set(${item}_OPENCV_ITEM)
endforeach()

foreach(item ${OPENCV_LIBS_3_1_X})
	find_library(${item}_OPENCV_ITEM
			${item} lib${item} ${item}${OPENCV_LIB_VER} lib${item}${OPENCV_LIB_VER}
			PATHS ${PROJECT_BASE_DIR}/redist/OpenCV/lib_${SPEC})
	if (${item}_OPENCV_ITEM)
		set(OPENCV_LIBRARIES ${OPENCV_LIBRARIES} ${${item}_OPENCV_ITEM})
	endif()
	set(${item}_OPENCV_ITEM)
endforeach()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OPENCV DEFAULT_MSG OPENCV_LIBRARIES OPENCV_INCLUDE_DIR)

MARK_AS_ADVANCED(
	OPENCV_INCLUDE_DIR
	OPENCV_LIBRARIES
)
