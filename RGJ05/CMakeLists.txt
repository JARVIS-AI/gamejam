cmake_minimum_required(VERSION 2.8.0)

project(RGJ05)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake-extras/")

set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_MULTITHREADED ON)

find_package(SFML 2 COMPONENTS audio graphics system window REQUIRED)
find_package(Bullet REQUIRED)
find_package(Boost COMPONENTS system filesystem REQUIRED)
find_package(ImageMagick COMPONENTS Magick++ REQUIRED)

add_definitions(-Wall -Wextra -Werror -Wno-unused-parameter -g -pedantic -fPIC -std=c++0x -DBOOST_FILESYSTEM_VERSION=3)
set(CMAKE_BUILD_TYPE "Debug")

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)

include_directories(
	"${CMAKE_SOURCE_DIR}/src/"
	${Boost_INCLUDE_DIRS}
	${BULLET_INCLUDE_DIRS}
	${SFML_INCLUDE_DIRS}
	${ImageMagick_INCLUDE_DIRS}
)

aux_source_directory(src/ sources)

include_directories(src/)

add_executable(loverobot-from-space
    ${sources}
)

target_link_libraries(loverobot-from-space
    ${Boost_LIBRARIES}
	${SFML_LIBRARIES}
    ${BULLET_LIBRARIES}
	${ImageMagick_LIBRARIES}
)
