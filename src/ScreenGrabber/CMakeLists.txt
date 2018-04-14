project(ZavScreenGrabber)

list(APPEND deps
	ZavScreenGrabberCore
)

set(is_win32_gui WIN32)

add_service(${PROJECT_NAME} ${deps})

if(WIN32)

	if (INSTALL_RUNTIME_LIBS)
		if (USE_QT5)
			include(DeployQt5)
			install_qt5_platform (${BINDIR})
			foreach(qt_lib ${qt_libs})
				string(REPLACE "Qt" "" qt_lib ${qt_lib})
				list(APPEND Qt5_COMMPONETS ${qt_lib})
			endforeach()
			install_qt5_lib (${BINDIR} ${Qt5_COMMPONETS})
			install_qt5_imageformats (${BINDIR} "qjpeg")
			install_qt5_audio(${BINDIR})
			install_qt_gleslibs(${BINDIR})
			if(MINGW)
				install_qt_mingw_rt (${BINDIR})
			endif(MINGW)
		endif()
	endif()
endif()
