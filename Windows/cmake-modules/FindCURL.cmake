
set(CURL_PATH "" CACHE STRING "CURL path")

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(CURL_LIB_PATH x64)
else()
	set(CURL_LIB_PATH x86)
endif()

find_path(CURL_INCLUDE_DIR curl/curl.h
	PATH_SUFFIXES include
	PATHS ${CURL_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/Windows/curl")

set(CURL_INCLUDE_DIRS "${CURL_INCLUDE_DIR}")

find_library(CURL_LIBRARY
	NAMES curl curllib libcurl_imp curllib_static libcurl libcurl_a
	PATH_SUFFIXES lib/${CURL_LIB_PATH}
	PATHS "${CURL_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/Windows/curl")

set(CURL_LIBRARIES "${CURL_LIBRARY}")

find_file(CURL_DLL
	NAMES libcurl.dll
	PATH_SUFFIXES lib/${CURL_LIB_PATH}
	PATHS ${SDL2_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/Windows/curl")

find_file(ZLIB1_DLL names zlib1.dll PATHS ${CMAKE_CURRENT_SOURCE_DIR}/Windows/zlib PATH_SUFFIXES ${CURL_LIB_PATH})

if (CURL_INCLUDE_DIR AND EXISTS "${CURL_INCLUDE_DIR}/curl/curlver.h")
	file(STRINGS "${CURL_INCLUDE_DIR}/curl/curlver.h" CURL_VERSION_MAJOR_LINE REGEX "^#define[ \t]+LIBCURL_VERSION_MAJOR[ \t]+[0-9]+$")
	file(STRINGS "${CURL_INCLUDE_DIR}/curl/curlver.h" CURL_VERSION_MINOR_LINE REGEX "^#define[ \t]+LIBCURL_VERSION_MINOR[ \t]+[0-9]+$")
	file(STRINGS "${CURL_INCLUDE_DIR}/curl/curlver.h" CURL_VERSION_PATCH_LINE REGEX "^#define[ \t]+LIBCURL_VERSION_PATCH[ \t]+[0-9]+$")
	string(REGEX REPLACE "^#define[ \t]+LIBCURL_VERSION_MAJOR[ \t]+([0-9]+)$" "\\1" CURL_VERSION_MAJOR "${CURL_VERSION_MAJOR_LINE}")
	string(REGEX REPLACE "^#define[ \t]+LIBCURL_VERSION_MINOR[ \t]+([0-9]+)$" "\\1" CURL_VERSION_MINOR "${CURL_VERSION_MINOR_LINE}")
	string(REGEX REPLACE "^#define[ \t]+LIBCURL_VERSION_PATCH[ \t]+([0-9]+)$" "\\1" CURL_VERSION_PATCH "${CURL_VERSION_PATCH_LINE}")
	set(CURL_VERSION_STRING ${CURL_VERSION_MAJOR}.${CURL_VERSION_MINOR}.${CURL_VERSION_PATCH})
	unset(CURL_VERSION_MAJOR_LINE)
	unset(CURL_VERSION_MINOR_LINE)
	unset(CURL_VERSION_PATCH_LINE)
	unset(CURL_VERSION_MAJOR)
	unset(CURL_VERSION_MINOR)
	unset(CURL_VERSION_PATCH)
endif()

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(CURL REQUIRED_VARS CURL_LIBRARY CURL_INCLUDE_DIR VERSION_VAR CURL_VERSION_STRING)

if (CURL_FOUND)
	if (CURL_LIBRARY)
		add_library(CURL::libcurl SHARED IMPORTED GLOBAL)
		set_target_properties(CURL::libcurl PROPERTIES IMPORTED_IMPLIB "${CURL_LIBRARY}" IMPORTED_LOCATION "${CURL_DLL}" INTERFACE_INCLUDE_DIRECTORIES "${CURL_INCLUDE_DIR}")
	endif()
endif()