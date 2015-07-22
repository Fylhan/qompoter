project(qompoter)
cmake_minimum_required(VERSION 2.8)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
find_package(Qt5Network)

set(SOURCES
    src/model/Config.cpp
    src/model/AuthorInfo.cpp
    src/model/PackageInfo.cpp
    src/model/Query.cpp
    src/model/QuerySettings.cpp
    src/model/RepositoryInfo.cpp
    src/model/RequireInfo.cpp
    src/model/TargetInfo.cpp
    src/model/PriorityMode.cpp
    src/model/BuildMode.cpp
    src/model/IncludeMode.cpp
    src/loader/ILoader.cpp
    src/loader/FsLoader.cpp
    src/loader/GitLoader.cpp
    src/loader/HttpLoader.cpp
    src/loader/InqludeLoader.cpp
    src/accessor/GitWrapper.cpp
    src/accessor/HttpWrapper.cpp
    src/IQompoter.cpp
    src/Qompoter.cpp
    src/commandline.cpp
    src/main.cpp
)

set(HEADERS
    src/model/Config.h
    src/model/AuthorInfo.h
    src/model/PackageInfo.h
    src/model/Query.h
    src/model/QuerySettings.h
    src/model/RequireInfo.h
    src/model/RepositoryInfo.h
    src/model/TargetInfo.h
    src/model/PriorityMode.h
    src/model/BuildMode.h
    src/model/IncludeMode.h
    src/loader/ILoader.h
    src/loader/FsLoader.h
    src/loader/GitLoader.h
    src/loader/HttpLoader.h
    src/loader/InqludeLoader.h
    src/accessor/GitWrapper.h
    src/accessor/HttpWrapper.h
    src/IQompoter.h
    src/Qompoter.h
    src/commandline.h
)

set(RESOURCES
    src/rsc/qompoter.qrc
)

include_directories(
    src
    src/model
    src/loader
    src/accessor
)

add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS} ${RESOURCES})
target_link_libraries(${PROJECT_NAME} Qt5::Network)
