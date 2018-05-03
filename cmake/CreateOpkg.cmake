# create .opk file
# You need to setup CPack first !

# DOCUMENTATION; You need to fill these values to set the control file:
# "Package: ${CPACK_PACKAGE_NAME}
#Version: ${CPACK_PACKAGE_VERSION}
#Description: ${CPACK_PACKAGE_DESCRIPTION_SUMMARY}
#Architecture: ${CPACK_OPKG_PACKAGE_ARCHITECTURE}
#Section: ${CPACK_OPKG_PACKAGE_SECTION}
#Priority: ${CPACK_OPKG_PACKAGE_PRIORITY}
#Maintainer: ${CPACK_OPKG_PACKAGE_MAINTAINER}
#Depends: ${CPACK_OPKG_PACKAGE_DEPENDS}
#Provides: ${CPACK_OPKG_PACKAGE_PROVIDES}
#Replaces: ${CPACK_OPKG_PACKAGE_REPLACES}
#Conflicts: ${CPACK_OPKG_PACKAGE_CONFLICTS}

if(UNIX)
	#FIND_PROGRAM(OPKG_CMD opkg-build)
	set (OPKG_CMD ${CMAKE_CURRENT_LIST_DIR}/opkg-build)
	if (NOT DEFINED "CPACK_PACKAGE_NAME")
		message(FATAL_ERROR "CPack was not included, you should include CPack before")
	endif ()

	macro(ADD_OPKG_TARGETS)
		set(OPKG_FILE_NAME "${CPACK_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}_${CPACK_OPKG_PACKAGE_ARCHITECTURE}")
		SET(CPACK_OPKG_ROOTDIR "${CMAKE_BINARY_DIR}/OPKG/${OPKG_FILE_NAME}")
		FILE(MAKE_DIRECTORY ${CPACK_OPKG_ROOTDIR})
		FILE(MAKE_DIRECTORY ${CPACK_OPKG_ROOTDIR}/CONTROL)
		set(CPACK_OPKG_CONTROL_FILE "${CPACK_OPKG_ROOTDIR}/CONTROL/control")

		FILE(WRITE ${CPACK_OPKG_CONTROL_FILE}
			"Package: ${CPACK_PACKAGE_NAME}
Version: ${CPACK_PACKAGE_VERSION}
Description: ${CPACK_PACKAGE_DESCRIPTION_SUMMARY}
Architecture: ${CPACK_OPKG_PACKAGE_ARCHITECTURE}
Section: ${CPACK_OPKG_PACKAGE_SECTION}
Priority: ${CPACK_OPKG_PACKAGE_PRIORITY}
Maintainer: ${CPACK_OPKG_PACKAGE_MAINTAINER}
Depends: ${CPACK_OPKG_PACKAGE_DEPENDS}
Provides: ${CPACK_OPKG_PACKAGE_PROVIDES}
Replaces: ${CPACK_OPKG_PACKAGE_REPLACES}
Conflicts: ${CPACK_OPKG_PACKAGE_CONFLICTS}
Source: n/a
")
		set(OPKG_FILE_NAME_WITH_EXT "${OPKG_FILE_NAME}.opk")

		add_custom_target(opkg_destdir_install
			COMMAND DESTDIR=${CMAKE_BINARY_DIR}/OPKG/${OPKG_FILE_NAME} ${CMAKE_MAKE_PROGRAM} install
			DEPENDS ${CMAKE_BINARY_DIR}/cmake_install.cmake
			COMMENT "Building opkg_package directory with DESTDIR"
		)

		if(OPKG_PREPACK_SCRIPT)
			add_custom_target(opkg_run_prepack_script
				COMMAND ${OPKG_PREPACK_SCRIPT} ${OPKG_PREPACK_SCRIPT_ARGS}
				COMMENT "Run prepack script in DESTDIR"
				WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/OPKG
				)
			add_dependencies(opkg_run_prepack_script opkg_destdir_install)
		endif()

		add_custom_command(
			OUTPUT    ${CMAKE_BINARY_DIR}/${OPKG_FILE_NAME_WITH_EXT}
			COMMAND   ${OPKG_CMD}
			ARGS      "-O" "-Z" "xz" "-o" "0" "${OPKG_FILE_NAME}" "${CMAKE_BINARY_DIR}"
			DEPENDS   ${CPACK_OPKG_CONTROL_FILE}
			COMMENT   "Generating opkg package"
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/OPKG
			)

		# the final target:
		add_custom_target(generate_opkg
			DEPENDS ${CMAKE_BINARY_DIR}/${OPKG_FILE_NAME_WITH_EXT}
		)

		if(OPKG_PREPACK_SCRIPT)
			add_dependencies(generate_opkg opkg_run_prepack_script)
		else()
			add_dependencies(generate_opkg opkg_destdir_install)
		endif()


		# BUG:${CMAKE_BINARY_DIR}/OPKG is not removed during a 'make clean':
		set_directory_properties(PROPERTIES
			ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_BINARY_DIR}/OPKG")

		endmacro()
endif()
