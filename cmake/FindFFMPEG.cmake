# - Try to find ffmpeg libraries (libavcodec, libavformat and libavutil)
# Once done this will define
#
#  FFMPEG_FOUND - system has ffmpeg or libav
#  FFMPEG_INCLUDE_DIR - the ffmpeg include directory
#  FFMPEG_LIBRARIES - Link these to use ffmpeg
#  FFMPEG_LIBAVCODEC
#  FFMPEG_LIBAVFORMAT
#  FFMPEG_LIBAVUTIL

if(FFMPEG_INCLUDE_DIR AND FFMPEG_LIBRARIES)
	set(FFMPEG_FIND_QUIETLY TRUE)
endif(FFMPEG_INCLUDE_DIR AND FFMPEG_LIBRARIES)

# use pkg-config to get the directories and then use these values
# in the FIND_PATH() and FIND_LIBRARY() calls
find_package(PkgConfig)
if (PKG_CONFIG_FOUND)
	pkg_check_modules(_FFMPEG_AVCODEC libavcodec)
	pkg_check_modules(_FFMPEG_AVFORMAT libavformat)
	pkg_check_modules(_FFMPEG_AVUTIL libavutil)
	pkg_check_modules(_FFMPEG_SWSCALE libswscale)
	pkg_check_modules(_FFMPEG_MFX libmfx)
endif (PKG_CONFIG_FOUND)

find_path(FFMPEG_AVCODEC_INCLUDE_DIR
	NAMES libavcodec/avcodec.h
	PATHS ${PROJECT_BASE_DIR}/redist/ffmpeg/include_${SPEC} ${_FFMPEG_AVCODEC_INCLUDE_DIRS} /usr/include /usr/local/include /opt/local/include /sw/include
	PATH_SUFFIXES ffmpeg libav
)

find_library(FFMPEG_LIBAVCODEC
	NAMES avcodec
	PATHS ${PROJECT_BASE_DIR}/redist/ffmpeg/lib_${SPEC} ${_FFMPEG_AVCODEC_LIBRARY_DIRS} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
)

find_library(FFMPEG_LIBAVFORMAT
	NAMES avformat
	PATHS ${PROJECT_BASE_DIR}/redist/ffmpeg/lib_${SPEC} ${_FFMPEG_AVFORMAT_LIBRARY_DIRS} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
)

find_library(FFMPEG_LIBAVUTIL
	NAMES avutil
	PATHS ${PROJECT_BASE_DIR}/redist/ffmpeg/lib_${SPEC} ${_FFMPEG_AVUTIL_LIBRARY_DIRS} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
)

find_library(FFMPEG_LIBSWSCALE
	NAMES swscale
	PATHS ${PROJECT_BASE_DIR}/redist/ffmpeg/lib_${SPEC} ${_FFMPEG_AVUTIL_LIBRARY_DIRS} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
)

find_library(FFMPEG_LIBMFX
	NAMES mfx
	PATHS ${PROJECT_BASE_DIR}/redist/ffmpeg/lib_${SPEC} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
)

find_library(FFMPEG_LIBSWRESAMPLE
		NAMES swresample
		PATHS ${PROJECT_BASE_DIR}/redist/ffmpeg/lib_${SPEC} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
)

find_library(FFMPEG_LIBAVFILTER
		NAMES avfilter
		PATHS ${PROJECT_BASE_DIR}/redist/ffmpeg/lib_${SPEC} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
)

find_library(FFMPEG_LIBAVDEVICE
		NAMES avdevice
		PATHS ${PROJECT_BASE_DIR}/redist/ffmpeg/lib_${SPEC} /usr/lib /usr/local/lib /opt/local/lib /sw/lib
)

if(FFMPEG_LIBAVCODEC AND FFMPEG_LIBAVFORMAT AND FFMPEG_LIBAVCODEC AND FFMPEG_LIBSWSCALE AND FFMPEG_LIBMFX)
	set(FFMPEG_FOUND TRUE)
endif()

if(FFMPEG_FOUND)
set(FFMPEG_INCLUDE_DIR ${FFMPEG_AVCODEC_INCLUDE_DIR})

set(FFMPEG_LIBRARIES
	${FFMPEG_LIBAVCODEC}
	${FFMPEG_LIBAVFORMAT}
	${FFMPEG_LIBAVUTIL}
	${FFMPEG_LIBSWSCALE}
	${FFMPEG_LIBSWRESAMPLE}
	${FFMPEG_AVFILTER}
	${FFMPEG_AVDEVICE}
	${FFMPEG_LIBMFX}
)

endif(FFMPEG_FOUND)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(FFMPEG DEFAULT_MSG FFMPEG_LIBRARIES FFMPEG_INCLUDE_DIR)

MARK_AS_ADVANCED(
	FFMPEG_INCLUDE_DIR
	FFMPEG_LIBRARIES
)
