function(install_qt5_file srcPath fileName destPath)
	set(QT_PREFIX "")

	if(CMAKE_BUILD_TYPE STREQUAL Debug)
		set(QT_PREFIX "d")
	endif(CMAKE_BUILD_TYPE STREQUAL Debug)

	install(FILES "${srcPath}/${fileName}${QT_PREFIX}.dll" DESTINATION ${destPath})
endfunction(install_qt5_file)

function(install_qt5_lib DEST)
	set (FilesToInstall)
	foreach(Qt5Lib ${ARGN})
		get_target_property(Qt5LibLocation Qt5::${Qt5Lib} LOCATION_${CMAKE_BUILD_TYPE})
		set (FilesToInstall ${FilesToInstall} ${Qt5LibLocation})
	endforeach(Qt5Lib ${ARGN})
	install(FILES ${FilesToInstall} DESTINATION ${DEST})
endfunction(install_qt5_lib)

function(install_qt5_plugins plugins_dir dest)
	foreach(plugin ${ARGN})
		install_qt5_file(${_qt5Core_install_prefix}/plugins/${plugins_dir} ${plugin}  ${dest}/${plugins_dir})
	endforeach(plugin)
endfunction(install_qt5_plugins)

function(install_qt5_sqldrivers dest)
	install_qt5_plugins("sqldrivers" ${dest} ${ARGN})
endfunction(install_qt5_sqldrivers)

function(install_qt5_imageformats dest)
	install_qt5_plugins("imageformats" ${dest} ${ARGN})
endfunction(install_qt5_imageformats)

function(install_qt5_audio dest)
	install_qt5_plugins("audio" ${dest} "qtaudio_windows")
endfunction(install_qt5_audio)

function(install_qt5_platform dest)
	install_qt5_plugins("platforms" ${dest} "qwindows")
endfunction(install_qt5_platform)

function(install_qt5_qml_plugin_qtquick2 dest)
	install_qt5_file(${_qt5Core_install_prefix}/qml/QtQuick.2 "qtquick2plugin" ${dest}/qml/QtQuick.2)
	install(FILES ${_qt5Core_install_prefix}/qml/QtQuick.2/qmldir DESTINATION ${dest}/qml/QtQuick.2)
endfunction(install_qt5_qml_plugin_qtquick2)

function(install_qt5_qml_plugin dest)
	foreach(plugin ${ARGN})
		if(${plugin} STREQUAL "QtQuick2")
			install_qt5_qml_plugin_qtquick2 (${dest})
		endif()
	endforeach(plugin)
endfunction(install_qt5_qml_plugin)

function(install_qt5_V8 dest)
	install_qt5_file(${_qt5Core_install_prefix}/bin Qt5V8 ${dest})
endfunction(install_qt5_V8)

function(install_qt5_icu dest)
	file(GLOB icu_libs ${_qt5Core_install_prefix}/bin/icu*.dll)
	install(FILES ${icu_libs} DESTINATION ${dest})
endfunction(install_qt5_icu)

function(install_qt_mingw_rt dest)
	file(GLOB gomp_libs ${_qt5Core_install_prefix}/bin/libgomp*.dll)
	install(FILES ${_qt5Core_install_prefix}/bin/libgcc_s_dw2-1.dll
		${_qt5Core_install_prefix}/bin/libstdc++-6.dll
		${_qt5Core_install_prefix}/bin/libwinpthread-1.dll
		${gomp_libs}
		DESTINATION ${dest})
endfunction(install_qt_mingw_rt)

function(install_qt_gleslibs dest)
	install(FILES ${_qt5Core_install_prefix}/bin/libEGL${BICYCLE_DEBUG_POSTFIX}.dll
		${_qt5Core_install_prefix}/bin/libGLESv2${BICYCLE_DEBUG_POSTFIX}.dll
		${_qt5Core_install_prefix}/bin/d3dcompiler_47.dll
		DESTINATION ${dest})
endfunction(install_qt_gleslibs)
