project(ZavScreenGrabberCore)

list(APPEND deps
	QTAVWIDGETS
	FFMPEG
)

#if(WITH_OPENMP)
#	if (OPENMP_FOUND)
#		set_property(SOURCE ${PROJECT_SOURCE_DIR}/internals/KmzConverter.cpp PROPERTY COMPILE_DEFINITIONS WITH_OPENMP APPEND)
#		set_property(SOURCE ${PROJECT_SOURCE_DIR}/internals/RasterConverter.cpp PROPERTY COMPILE_DEFINITIONS WITH_OPENMP APPEND)
#	endif()
#endif()

#if(USE_SQLITE_DATABASE)
#	set_property(SOURCE ${PROJECT_SOURCE_DIR}/core/pureimagecache.cpp PROPERTY COMPILE_DEFINITIONS USE_SQLITE_DATABASE APPEND)
#endif()

add_lib_static(${PROJECT_NAME} ${deps})
