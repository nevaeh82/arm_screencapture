# ---------------------------------------------------------------------------
# GET_RELATIVE_SOURCES
# Given a list of sources, return the corresponding relative paths to
# a directory.
# 'varname': name of the var the list of absolute paths should be stored into
# 'dir': path to the dir we want relative path from
# 'sources': list of *absolute* path to the source files

macro(GET_RELATIVE_SOURCES varname dir sources)

	get_filename_component(dir_abs ${dir} ABSOLUTE)

	set(${varname})
	foreach(file ${sources})
		file(RELATIVE_PATH rel_file "${dir}" "${file}")
		set(${varname} ${${varname}} ${rel_file})
	endforeach(file)

endmacro(GET_RELATIVE_SOURCES)

macro(InstallSymlink _filepath _sympath)
	get_filename_component(_symname ${_sympath} NAME)
	get_filename_component(_installdir ${_sympath} PATH)

	if (BINARY_PACKAGING_MODE)
		execute_process(COMMAND "${CMAKE_COMMAND}" -E create_symlink
			${_filepath}
			${CMAKE_CURRENT_BINARY_DIR}/${_symname})
		install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${_symname}
			DESTINATION ${_installdir})
	else ()
		# scripting the symlink installation at install time should work
		# for CMake 2.6.x and 2.8.x
		install(CODE "
			message(STATUS \"Created symlink: ${_filepath} -> ${_sympath}\")
			if (\"\$ENV{DESTDIR}\" STREQUAL \"\")
				execute_process(COMMAND \"${CMAKE_COMMAND}\" -E create_symlink
					${_filepath}
					${_installdir}/${_symname})
			else ()
				execute_process(COMMAND \"${CMAKE_COMMAND}\" -E create_symlink
					${_filepath}
					\$ENV{DESTDIR}/${_installdir}/${_symname})
			endif ()
			")
	endif ()
endmacro(InstallSymlink)

## Creates executable application.
macro( add_service projectname )
	include_directories( ${${projectname}_SOURCE_DIR} ${${projectname}_BINARY_DIR} )

	extract_project_options( sources dependencies ${ARGN} )
	init_libs( ${dependencies} )
	build_project_tree( ${projectname} ${sources} )
	add_version_info( ${projectname} NO ${srcs} )
	add_executable( ${projectname} ${is_win32_gui} ${srcs} ${hdrs} )

	if(${projectname}_AUTOMOC)
		set_target_properties(${projectname} PROPERTIES AUTOMOC ON)
	endif()

	if( Threads_FOUND )
		list( APPEND libs ${CMAKE_THREAD_LIBS_INIT} )
	endif()

	target_link_libraries( ${projectname} ${libs} )
	install( TARGETS ${projectname} RUNTIME DESTINATION ${BINDIR} )

	if(WIN32 AND NOT ${is_win32_gui})
		if(CMAKE_COMPILER_IS_GNUCXX)
			set_target_properties( ${projectname} PROPERTIES LINK_FLAGS -Wl,--subsystem,console)
		elseif(MSVC)
			set_target_properties( ${projectname} PROPERTIES LINK_FLAGS LINK_FLAGS /SUBSYSTEM:CONSOLE)
		endif(CMAKE_COMPILER_IS_GNUCXX)
	endif(WIN32 AND NOT ${is_win32_gui})

	if( INSTALL_LIBS )
		list( REMOVE_DUPLICATES libs )

		foreach( lib ${libs} )
			if( NOT ${lib} MATCHES ${PROJECT_NAME_GLOBAL} )
				string( REPLACE "libPwLoggerLib.a" "PwLoggerLib.dll" lib ${lib} )
				string( REPLACE "libPwLoggerLibd.a" "PwLoggerLibd.dll" lib ${lib} )

				string( REGEX REPLACE "^(optimized|debug|.*\\.a)$" "" lib ${lib} )

				if( EXISTS ${lib} )
					list( APPEND thirdparty ${lib} )
				endif()
			endif()
		endforeach()

		install( FILES ${thirdparty} DESTINATION ${LIBDIR} )
	endif()
endmacro()

## Creates executable CxxTest and adds it to tests list.
macro( add_bicycle_test projectname )

	include_directories( ${${projectname}_SOURCE_DIR} ${${projectname}_BINARY_DIR} )
	include_directories( ${PROJECT_BASE_DIR}/tools )
	include_directories( ${PROJECT_BASE_DIR}/tools/cxxtest )
	include_directories( ${PROJECT_BASE_DIR}/tools/cxxmock )
	include_directories( ${PROJECT_BASE_DIR}/src/TestShared )

	set( srcs_gen ${${projectname}_BINARY_DIR}/testsuite.generated.cpp )
	list( APPEND hdrs_for_moc
		${PROJECT_BASE_DIR}/src/TestShared/QApplicationRunner.h
		${PROJECT_BASE_DIR}/src/TestShared/QSignalCounter.h
		)

	extract_test_options( sources dependencies mocks paths ${ARGN} )
	init_libs( ${dependencies} )
	build_project_tree( ${projectname} ${sources})

	# add command to generate test suite
	list( REMOVE_ITEM srcs ${${projectname}_SOURCE_DIR}/testsuite.generated.cpp ${${projectname}_SOURCE_DIR}/testsuite.cpp )
	add_custom_command(
		OUTPUT ${srcs_gen}
		COMMAND ${PYTHON} ${PROJECT_BASE_DIR}/tools/cxxtest/cxxtestgen.py --have-eh --have-std --abort-on-fail --template ${PROJECT_BASE_DIR}/src/TestShared/runner.tpl -o ${srcs_gen} ${hdrs}
		DEPENDS ${hdrs}
		WORKING_DIRECTORY ${${projectname}_SOURCE_DIR}
		COMMENT "Generate tests for ${projectname}"
		)

	# add command to generate mocks if we had mocks from ARGS or ${need_mock_gen} = TRUE
	list( LENGTH mocks mocks_size )
	if( mocks_size GREATER 0 OR need_mock_gen )
		# if ${mock_get} is empty, set it by default
		if( "${mock_gen}" STREQUAL "" )
			set( mock_gen "${${projectname}_BINARY_DIR}/Mocks.generated.h" )
		endif()

		# add external list of mocks for old style specifications
		list( APPEND mocks "${mock_interfaces}" )

		add_custom_command(
			OUTPUT ${mock_gen}
			COMMAND ${PYTHON} ${PROJECT_BASE_DIR}/tools/cxxmock/cxxmockgen.py -o ${mock_gen} ${mocks}
			DEPENDS ${mocks}
			WORKING_DIRECTORY ${${projectname}_SOURCE_DIR}
			COMMENT "Generate mocks for ${projectname}"
			)
	else()
		# don't use ${mock_gen} if we havn't list of mocks
		set( mock_gen )
	endif()

	add_executable( ${projectname}
		${srcs}
		${hdrs}
		${srcs_gen}
		${mock_gen})

	if(${projectname}_AUTOMOC)
		set_target_properties(${projectname} PROPERTIES AUTOMOC ON)
	endif()

	if( Threads_FOUND )
		list( APPEND libs ${CMAKE_THREAD_LIBS_INIT} )
	endif()

	target_link_libraries( ${projectname} ${libs} )

	if( INSTALL_TESTS )
		install( TARGETS ${projectname} RUNTIME DESTINATION ${BINDIR} )
	endif()

	if( hwtest )
		install( TARGETS ${projectname} RUNTIME DESTINATION ${BINDIR} )
	else()
		add_test( NAME ${projectname} COMMAND ${projectname} WORKING_DIRECTORY ${${projectname}_SOURCE_DIR})
		#add_test( NAME ${projectname} COMMAND ${CMAKE_COMMAND} -E environment )
		if( WIN32 )
			if (libs_path)
				list(REMOVE_DUPLICATES libs_path)
			endif()
			list( APPEND bycicle_path ${paths} ${libs_path} ${add_to_sys_path} $ENV{PATH} )
			if (bycicle_path)
				list( REMOVE_DUPLICATES bycicle_path )
			endif()

			foreach(b ${bycicle_path})
				string(REPLACE "\\" "/" b ${b})
				string(REGEX REPLACE "^(.+Qt.+)/lib$" "\\1/bin" b ${b} )
				list(APPEND bycicle_path_rel ${b})
			endforeach()

			string( REPLACE ";" "\\;" bycicle_path_final "${bycicle_path_rel}" )
			set_property( TEST ${projectname} APPEND PROPERTY ENVIRONMENT "PATH=${bycicle_path_final}" )

			if(CMAKE_COMPILER_IS_GNUCXX)
				set_target_properties( ${projectname} PROPERTIES LINK_FLAGS -Wl,--subsystem,console)
			elseif(MSVC)
				set_target_properties( ${projectname} PROPERTIES LINK_FLAGS /SUBSYSTEM:CONSOLE)
			endif(CMAKE_COMPILER_IS_GNUCXX)
		#else()
		#	list( APPEND bycicle_path ${libs_path} ${add_to_sys_path})
		#	list( REMOVE_DUPLICATES bycicle_path )
		#	string( REPLACE ";" ":" bycicle_path_final "${bycicle_path}" )
		#	set_property( TEST ${projectname} APPEND PROPERTY ENVIRONMENT "LD_LIBRARY_PATH=${bycicle_path_final}")
		endif()
	endif()
endmacro()

## Creates executable Catch test and adds it to tests list.
macro( add_catch_test projectname )

	include_directories( ${${projectname}_SOURCE_DIR} ${${projectname}_BINARY_DIR} )
	include_directories( ${PROJECT_BASE_DIR}/tools/QCatchTest )

	set( qtest_catch_src ${PROJECT_BASE_DIR}/tools/QCatchTest/QCatchTest.cpp )
	set( hdrs_for_moc ${PROJECT_BASE_DIR}/tools/QCatchTest/QCatchTest.h )

	extract_test_options( sources dependencies mocks paths ${ARGN} )
	init_libs( ${dependencies} )
	build_project_tree( ${projectname} ${sources} )

	add_executable( ${projectname}
		${srcs}
		${hdrs}
		${qtest_catch_src})

	if(${projectname}_AUTOMOC)
		set_target_properties(${projectname} PROPERTIES AUTOMOC ON)
	endif()

	if( Threads_FOUND )
		list( APPEND libs ${CMAKE_THREAD_LIBS_INIT} )
	endif()

	target_link_libraries( ${projectname} ${libs} )

	if( INSTALL_TESTS )
		install( TARGETS ${projectname} RUNTIME DESTINATION ${BINDIR} )
	endif()

	if( hwtest )
		install( TARGETS ${projectname} RUNTIME DESTINATION ${BINDIR})
	else()
		add_test( NAME ${projectname} COMMAND ${projectname} WORKING_DIRECTORY ${${projectname}_SOURCE_DIR})
		#add_test( NAME ${projectname} COMMAND ${CMAKE_COMMAND} -E environment )
		list(LENGTH libs_path libs_path_len)
		if( WIN32 AND libs_path_len)
			list(REMOVE_DUPLICATES libs_path)
			list( APPEND bycicle_path ${paths} ${libs_path} ${add_to_sys_path} $ENV{PATH} )
			list( REMOVE_DUPLICATES bycicle_path )

			foreach(b ${bycicle_path})
				string(REPLACE "\\" "/" b ${b})
				string(REGEX REPLACE "^(.+Qt.+)/lib$" "\\1/bin" b ${b} )
				list(APPEND bycicle_path_rel ${b})
			endforeach()

			string( REPLACE ";" "\\;" bycicle_path_final "${bycicle_path_rel}" )

			set_property( TEST ${projectname} APPEND PROPERTY ENVIRONMENT "PATH=${bycicle_path_final}" )

			if(CMAKE_COMPILER_IS_GNUCXX)
				set_target_properties( ${projectname} PROPERTIES LINK_FLAGS -Wl,--subsystem,console)
			elseif(MSVC)
				set_target_properties( ${projectname} PROPERTIES LINK_FLAGS /SUBSYSTEM:CONSOLE)
			endif(CMAKE_COMPILER_IS_GNUCXX)
		#else()
		#	list( APPEND bycicle_path ${libs_path} ${add_to_sys_path})
		#	list( REMOVE_DUPLICATES bycicle_path )
		#	string( REPLACE ";" ":" bycicle_path_final "${bycicle_path}" )
		#	set_property( TEST ${projectname} APPEND PROPERTY ENVIRONMENT "LD_LIBRARY_PATH=${bycicle_path_final}")
		endif()
	endif()
endmacro()

## Creates library with ${projectname}.
## Use SET( link STATIC ) or SET( link SHARED ) to create suitable lib.
macro( add_lib projectname )
	if( NOT USE_QT5 )
		include( ${QT_USE_FILE} )
		list( APPEND add_lib_internal_deps QT)
	else()
		foreach(qt_lib ${qt_libs})
			string(REPLACE "Qt" "Qt5" qt_lib ${qt_lib})
			list(APPEND add_lib_internal_deps ${qt_lib})
		endforeach()
	endif()

	include_directories( ${${projectname}_SOURCE_DIR} ${${projectname}_BINARY_DIR} )
	extract_project_options( sources dependencies "${ARGN}" )

	list(APPEND add_lib_internal_deps ${dependencies})
	init_libs( ${add_lib_internal_deps} )
	build_project_tree( ${projectname} ${sources} )

	if( link MATCHES SHARED )
		add_version_info( ${projectname} YES ${srcs} )
	endif()

	add_library( ${projectname} ${link} ${srcs} ${hdrs} )

	get_target_property(${projectname}_INCDIR ${projectname} INCLUDE_DIRECTORIES)
	list(REMOVE_DUPLICATES ${projectname}_INCDIR)
	set_property(TARGET ${projectname} PROPERTY INCLUDE_DIRECTORIES "${${projectname}_INCDIR}")

	if(${projectname}_AUTOMOC)
		set_target_properties(${projectname} PROPERTIES AUTOMOC ON)
	endif()

	if( WIN32 )
		set_property( TARGET ${projectname} PROPERTY PREFIX "" )
	endif()

	if( INSTALL_ARCHIVE_LIBS )
		install (TARGETS ${projectname} ARCHIVE DESTINATION ${LIBDIR})
	endif()

	if( Threads_FOUND )
		list( APPEND libs ${CMAKE_THREAD_LIBS_INIT} )
	endif()

	if( NOT WIN32 )
		set_property( TARGET ${projectname} PROPERTY COMPILE_FLAGS -fPIC )
	endif()

	target_link_libraries( ${projectname} ${libs} )

	set( ${projectname}_LIBS ${libs} PARENT_SCOPE )
	set( ${projectname}_LIBS_PATH ${libs_path} PARENT_SCOPE )
endmacro()

## Creates static lib.
macro( add_lib_static projectname )
	set( link STATIC )
	add_lib( ${projectname} ${ARGN} )
endmacro()

## Creates shared lib.
macro( add_lib_shared projectname )
	set( link SHARED )

	add_lib( ${projectname} ${ARGN} )

	install( TARGETS ${projectname}
		RUNTIME DESTINATION ${LIBDIR}
		LIBRARY DESTINATION ${LIBDIR})

	if( INSTALL_LIBS )
		list( REMOVE_DUPLICATES libs )

		foreach( lib ${libs} )
			if( NOT ${lib} MATCHES ${PROJECT_NAME_GLOBAL} )
				string( REPLACE "libPwLoggerLib.a" "PwLoggerLib.dll" lib ${lib} )
				string( REPLACE "libPwLoggerLibd.a" "PwLoggerLibd.dll" lib ${lib} )

				string( REGEX REPLACE "^(optimized|debug|.*\\.a)$" "" lib ${lib} )

				if( EXISTS ${lib} )
					list( APPEND thirdparty ${lib} )
				endif()
			endif()
		endforeach()

		install( FILES ${thirdparty} DESTINATION ${LIBDIR} )
	endif()
endmacro()

## Builds project files tree.
macro( build_project_tree projectname )

	if(USE_QT5)
		set(QT_LRELEASE_EXECUTABLE ${Qt5_LRELEASE_EXECUTABLE})
		get_target_property(QT_RCC_EXECUTABLE Qt5::rcc LOCATION)
	endif()

	# detect path to project folder relative current cmake folder
	file( RELATIVE_PATH path ${CMAKE_CURRENT_SOURCE_DIR} ${${projectname}_SOURCE_DIR} )
	if( path )
		set( path "${path}/" )
	endif()

	# scan for project source files
	file( GLOB_RECURSE srcs ${path}*.cpp ${path}*.cc ${path}*.c )

	file( GLOB_RECURSE hdrs ${path}*.h ${path}*.hpp )
	file( GLOB_RECURSE ui_forms ${path}*.ui )
	file( GLOB_RECURSE qrcs ${path}*.qrc )
	file( GLOB_RECURSE rcs ${path}*.rc )
	file( GLOB_RECURSE tssr ${path}*.ts )

	file( GLOB_RECURSE protos *.proto )
	file( GLOB_RECURSE protosin *.proto.in )

	foreach( proto ${exclude_proto} )
		list( REMOVE_ITEM protos ${proto} )
	endforeach()

	list(APPEND protos ${add_proto})

	foreach( protoin ${exclude_protoin} )
		list( REMOVE_ITEM protosin ${protoin} )
	endforeach()

	list(APPEND protosin ${add_protoin})

	list( APPEND srcs ${protosin})

	foreach(protoin_item ${protosin})
		get_filename_component(protoin_file_name ${protoin_item} NAME_WE)

		if(PROTOBUF_FULL_LIB)
			set(PROTOBUF_FULL_LIB_STRING "")
		else()
			set(PROTOBUF_FULL_LIB_STRING "option optimize_for = LITE_RUNTIME;")
		endif()

		set(dest_protoin_file ${${projectname}_BINARY_DIR}/${protoin_file_name}.proto)
		configure_file(${protoin_item} ${dest_protoin_file})
		set_property(SOURCE ${dest_protoin_file} PROPERTY GENERATED ON)
		list(APPEND protos ${dest_protoin_file})
	endforeach()

	foreach( cpp ${exclude_cpp} )
		list( REMOVE_ITEM srcs ${cpp} )
	endforeach()

	list(APPEND srcs ${add_cpp})

	foreach( h ${exclude_h} )
		list( REMOVE_ITEM hdrs ${h} )
	endforeach()

	list(APPEND hdrs ${add_h})

	foreach( ui ${exclude_ui} )
		list( REMOVE_ITEM ui_forms ${ui} )
	endforeach()

	list(APPEND ui_forms ${add_ui})

	foreach( qrc ${exclude_qrc} )
		list( REMOVE_ITEM qrcs ${qrc} )
	endforeach()

	list(APPEND qrcs ${add_qrc})

	foreach( rc ${exclude_rc} )
		list( REMOVE_ITEM rcs ${rc} )
	endforeach()

	list(APPEND rcs ${add_rc})

	list( APPEND srcs ${rcs} )

	# get all files from qresurces to include it in project tree
	foreach( qrc ${qrcs} )
		file( READ ${qrc} qrc_data )
		get_filename_component( qrc_dir ${qrc} PATH )
		string( REGEX MATCHALL "<file[^>]*>[^<]+" qrc_files ${qrc_data} )
		string( REGEX REPLACE "<file[^>]*>" "${qrc_dir}/" qrc_files "${qrc_files}" )
		list( APPEND srcs "${qrc_files}" )
	endforeach()

	list(LENGTH protos protos_len)

	if(protos_len GREATER 0)
		list( APPEND srcs ${protos})
		foreach(proto_item ${protos})
			get_filename_component(proto_item_NAME ${proto_item} NAME_WE)
			get_filename_component(proto_item_DIR ${proto_item} PATH)
			set(protos_out ${${projectname}_BINARY_DIR}/${proto_item_NAME}.pb.cc ${${projectname}_BINARY_DIR}/${proto_item_NAME}.pb.h)
			get_property(a3 SOURCE ${proto_item} PROPERTY GENERATED)

			list(APPEND proto_path "--proto_path=${PROTOBUF_INCLUDE_DIR}")

			if (a3)
				list(APPEND proto_path "--proto_path=${proto_item_DIR}" "--proto_path=${${projectname}_BINARY_DIR}" "--proto_path=${${projectname}_SOURCE_DIR}")
				foreach(lib ${libs} )
					if(${lib} MATCHES ${PROJECT_NAME_GLOBAL} )
						list(APPEND proto_path "--proto_path=${${lib}_BINARY_DIR}" "--proto_path=${${lib}_SOURCE_DIR}")
					endif()
				endforeach()
			else()
				set(proto_path "--proto_path=${proto_item_DIR}")
			endif()
			list(APPEND protos_out_all ${protos_out})
			list(REMOVE_DUPLICATES proto_path)
			list(APPEND srcs ${protos_out})
			set_source_files_properties(${protos_out} PROPERTIES GENERATED TRUE)

			add_custom_command(
				COMMAND ${PROTOBUF_COMPILER}
				ARGS ${proto_path} --cpp_out="${${projectname}_BINARY_DIR}" ${proto_item}
				DEPENDS ${proto_item}
				OUTPUT ${protos_out}
				)
		endforeach()

		add_custom_target(${projectname}_protobuf_autogen ALL DEPENDS ${protos_out_all})

	endif()

	if( NOT CMAKE_AUTOMOC AND NOT ${projectname}_AUTOMOC )
		foreach( header ${hdrs} )
			file( STRINGS "${header}" lines REGEX "Q_OBJECT" )

			if( lines )
				list( APPEND hdrs_for_moc "${header}" )
			endif()
		endforeach()

		if( NOT USE_QT5 )
			qt4_wrap_cpp( m_srcs ${hdrs_for_moc} OPTIONS ${MOC_ARGS} )
		else()
			qt5_wrap_cpp( m_srcs ${hdrs_for_moc} OPTIONS ${MOC_ARGS} )
		endif()

		list( APPEND srcs ${m_srcs} )
	else()
		list( APPEND srcs ${hdrs_for_moc} )
	endif()

	if( NOT CMAKE_AUTOUIC AND ui_forms )
		if( NOT USE_QT5 )
			qt4_wrap_ui( u_srcs ${ui_forms} )
		else()
			qt5_wrap_ui( u_srcs ${ui_forms} )
		endif()

		list( APPEND srcs ${u_srcs} )
	endif()

	if(CREATE_TR)
		foreach(lang ${LANGUAGES})
			foreach(ts ${tssr})
				get_filename_component(ts_NAME ${ts} NAME_WE)
				string(FIND ${ts_NAME} "_${lang}" check_ts)
				if(${check_ts} GREATER 0)
					set(qm ${${projectname}_BINARY_DIR}/${ts_NAME}.qm)
					list(APPEND qms ${qm})
					list(APPEND srcs ${ts})
					add_custom_command(
						OUTPUT "${qm}"
						DEPENDS "${ts}"
						COMMAND ${QT_LRELEASE_EXECUTABLE}
						ARGS "${ts}" -qm "${qm}")
				endif()
			endforeach()
		endforeach()

		list(LENGTH qms qms_len)

		if( qms_len GREATER 0)
			set(translations_qrc "${${projectname}_BINARY_DIR}/${projectname}_ts.qrc")
			set(translations_qrc_cache_file "${${projectname}_BINARY_DIR}/${projectname}_ts.qrc_cache")
			if(EXISTS ${translations_qrc_cache_file})
				file(READ ${translations_qrc_cache_file} translations_qrc_cache)
			endif()
			foreach(qm_file ${qms})
				list(APPEND translations_qrc_current ${qm_file})
			endforeach()
			if (translations_qrc_current STREQUAL translations_qrc_cache)
			else()
				unset(translations_qrc_cache)
				file(WRITE ${translations_qrc} "<RCC>\n\t<qresource prefix=\"/\">")
				foreach(qm_file ${qms})
					list(APPEND translations_qrc_cache ${qm_file})
					get_filename_component(qm_file_NAME ${qm_file} NAME)
					file(APPEND ${translations_qrc} "\n\t\t<file alias=\"${qm_file_NAME}\">${qm_file_NAME}</file>")
				endforeach()
				file(APPEND ${translations_qrc} "\n\t</qresource>\n</RCC>")
				file(WRITE ${translations_qrc_cache_file} ${translations_qrc_cache})
			endif()
			list(APPEND qrcs ${translations_qrc})
			add_custom_target(${projectname}_translate_autogen ALL DEPENDS ${qms})
		endif()
	endif()

	if( NOT CMAKE_AUTORCC )
		foreach( qrc ${qrcs} )
			if( NOT USE_QT5 )
				qt4_add_resources( qrcc ${qrc} )
			else()
				qt5_add_resources( qrcc ${qrc} )
			endif()
		endforeach()

		list( APPEND srcs ${qrcc} )
	else()
		list( APPEND srcs ${qrcs} )
	endif()

endmacro()

## Creates list of libs for dependencies.
macro( init_libs )
	unset( libs )
	unset( libs_path )
	unset( ${projectname}_ctest_libs_path)

	foreach( dep ${ARGN} )
		string( TOUPPER ${dep} depUp )

		if( ${dep} MATCHES ${PROJECT_NAME_GLOBAL} )
			get_target_property( INCLUDE_DIRS ${dep} INCLUDE_DIRECTORIES )
			include_directories( ${${dep}_SOURCE_DIR} ${INCLUDE_DIRS} )

			list( APPEND libs ${${dep}_LIBS} ${dep} )
			get_target_property( typelink ${dep} TYPE )

			#STATIC_LIBRARY, MODULE_LIBRARY, SHARED_LIBRARY, EXECUTABLE

			if ( ${typelink} STREQUAL "MODULE_LIBRARY" OR ${typelink} STREQUAL "SHARED_LIBRARY")
				list( APPEND libs_path ${${dep}_LIBS_PATH} ${${dep}_BINARY_DIR} )
			endif()

			get_target_property(${dep}_libs ${dep} LINK_LIBRARIES)

			foreach(lib ${${dep}_libs})
				get_filename_component(lib_name ${lib} NAME_WE)
				if( ${lib_name} MATCHES ${PROJECT_NAME_GLOBAL} )
					list(APPEND ${dep}_ctest_libs_path ${${lib}_ctest_libs_path})
				else()
					get_filename_component(lib_dir ${lib} PATH)
					string(LENGTH "x${lib_dir}" lib_dir_len)
					if (lib_dir_len GREATER 1)
						string(REGEX REPLACE "^\\$<.+>\\:" "" lib_dir ${lib_dir})
						list(APPEND ${dep}_ctest_libs_path ${lib_dir})
					endif()
				endif()
			endforeach()

			if (${dep}_ctest_libs_path)
				list(REMOVE_DUPLICATES ${dep}_ctest_libs_path)
				set (${dep}_ctest_libs_path ${${dep}_ctest_libs_path} PARENT_SCOPE)
				list(APPEND libs_path ${${dep}_ctest_libs_path})
			endif()

		else()
			include_directories(
				${${dep}_INCLUDE_DIR} ${${dep}_INCLUDE_DIRS}
				${${depUp}_INCLUDE_DIR} ${${depUp}_INCLUDE_DIRS}
				${${dep}_INCLUDES} ${${depUp}_INCLUDES}
				${${dep}_PRIVATE_INCLUDE_DIRS} ${${depUp}_PRIVATE_INCLUDE_DIRS}
				)

			if(${dep}_LDFLAGS OR ${depUp}_LDFLAGS)
				list( APPEND libs ${${dep}_LDFLAGS} ${${depUp}_LDFLAGS})
			else()
				list( APPEND libs ${${dep}_LIBRARIES} ${${depUp}_LIBRARIES})
			endif()

			list( APPEND libs  ${${dep}_LIBRARY}  ${${depUp}_LIBRARY} )

			set( depLibs ${${depUp}_LIBRARIES} ${${depUp}_LIBRARY} )
			foreach( depLib ${depLibs} )
				get_filename_component( depLibPath ${depLib} PATH )
				list( APPEND libs_path ${depLibPath} )

				# We can use it instead specifying full path to libarary
				#get_filename_component( depLibName ${depLib} NAME_WE )
				#string( REGEX REPLACE "^lib" "" depLibName ${depLibName} )
				#list( APPEND libs ${depLibName} )
			endforeach()
		endif()
	endforeach()
endmacro()

## Finds required packages.
macro( find_packages )
	foreach( package ${ARGN} )
		find_package( ${package} REQUIRED )
	endforeach()
endmacro()

## Finds required packages and adds them as
## dependencies for project (append to deps).
macro( add_thirdparty )
	find_packages( ${ARGN} )
	list( APPEND deps ${ARGN} )
endmacro()

## Adds Windows VersionInfo for DLL or EXE targets
macro( add_version_info projectname dll srcs )
	# add resource with VersionInfo to Windows application
	if( WIN32 )
		if( ${dll} )
			set( VERSION_INFO_SRC ${PROJECT_BASE_DIR}/src/DllVersionInfo.rc )
		else()
			set( VERSION_INFO_SRC ${PROJECT_BASE_DIR}/src/AppVersionInfo.rc )
		endif()

		if( EXISTS ${VERSION_INFO_SRC} )
			set( VERSION_INFO_RC ${PROJECT_BINARY_DIR}/VersionInfo.rc )

			if( NOT PROJECT_DESCRIPTION )
				set( PROJECT_DESCRIPTION "" )
			endif()

			string( TIMESTAMP CURRENT_YEAR "%Y" )

			if( ${dll} )
				set( FILENAME_PREFIX "${CMAKE_SHARED_MODULE_PREFIX}" )
				set( FILENAME_SUFFIX "${CMAKE_SHARED_MODULE_SUFFIX}" )
			else()
				set( FILENAME_PREFIX "" )
				set( FILENAME_SUFFIX "${CMAKE_EXECUTABLE_SUFFIX}" )
			endif()

			string( TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_UP )
			set( PROJECT_FILENAME "${FILENAME_PREFIX}${projectname}${CMAKE_${CMAKE_BUILD_TYPE_UP}_POSTFIX}${FILENAME_SUFFIX}" )

			configure_file( ${VERSION_INFO_SRC} ${VERSION_INFO_RC} )
			list( APPEND srcs ${VERSION_INFO_RC} )
		endif()
	endif()
endmacro()

## Extract options for project
## Usage: extract_project_options( <project name> <sources variable> <dependencies variable> [SOURCES <list of sources>] [DEPENDENCIES <list of dependencies>] )
## Usage for old style: extract_project_options( <project name> <sources variable> <dependencies variable> <list of dependencies> )
function( extract_project_options _sources _dependencies )
	set( srcs )
	set( deps )

	# init start state of loop
	if( ARGN AND ${ARGC} GREATER 2 )
		list( GET ARGN 0 first )

		if ( "x${first}" STREQUAL "xSOURCES" )
			set( DOING_SOURSES TRUE )
			set( DOING_DEPENDENCIES FALSE )
		else()
			set( DOING_SOURSES FALSE )
			set( DOING_DEPENDENCIES TRUE )

			# if we had no argument label "SOURCES" or "DEPENDENCIES"
			# that mean we use simple style of the command (dep1; dep2; dep3)
			# and we sould collect list of dependencies from zero item
			if ( NOT "x${first}" STREQUAL "xDEPENDENCIES" )
				list( APPEND deps ${first} )
			endif()
		endif()

		# remove first item because it was processed
		list( REMOVE_AT ARGN 0 )
	endif()

	foreach( item ${ARGN} )
		if( "x${item}" STREQUAL "xSOURCES" )
			set( DOING_SOURSES TRUE )
		elseif( "x${item}" STREQUAL "xDEPENDENCIES" )
			set( DOING_DEPENDENCIES TRUE )
		else()
			if( DOING_DEPENDENCIES )
				list( APPEND deps "${item}" )
			elseif( DOING_SOURSES )
				list( APPEND srcs "${item}" )
			endif()
		endif()
	endforeach()

	set( ${_sources} ${srcs} PARENT_SCOPE )
	set( ${_dependencies} ${deps} PARENT_SCOPE )
endfunction()


## Extract options for test project.
## Works similar as function extract_project_options, but has an additional options MOCKS & PATH.
## Usage: extract_test_options( <project name> <sources variable> <dependencies variable> <mocks variable> <path variable> [SOURCES <list of sources>] [DEPENDENCIES <list of dependencies>] [MOCKS <list of files>] [PATH <list of paths>] )
## Usage for old style: extract_test_options( <project name> <sources variable> <dependencies variable> <mocks variable> <path variable> <list of dependencies> )
function( extract_test_options _sources _dependencies _mocks _paths )
	extract_project_options( srcs deps ${ARGN} )

	set( paths )
	set( mocks )

	set( DOING_PATHS FALSE )
	set( DOING_MOCKS FALSE )

	foreach( item ${deps} )
		set( REMOVE_ITEM TRUE )

		if( "x${item}" STREQUAL "xMOCKS" )
			set( DOING_MOCKS TRUE )
		elseif( "x${item}" STREQUAL "xPATH" )
			set( DOING_PATHS TRUE )
		else()
			if( DOING_PATHS )
				list( APPEND paths "${item}" )
			elseif( DOING_MOCKS )
				list( APPEND mocks "${item}" )
			else()
				set( REMOVE_ITEM FALSE )
			endif()
		endif()

		if( REMOVE_ITEM )
			list( REMOVE_ITEM deps ${item} )
		endif()
	endforeach()

	set( ${_sources} ${srcs} PARENT_SCOPE )
	set( ${_dependencies} ${deps} PARENT_SCOPE )
	set( ${_mocks} ${mocks} PARENT_SCOPE )
	set( ${_paths} ${paths} PARENT_SCOPE )
endfunction()
