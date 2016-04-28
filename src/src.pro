DEPENDPATH += $$PWD
INCLUDEPATH += $$PWD $$PWD/. $$PWD/..

TARGET = qompoter
TEMPLATE = app
QT += network
CONFIG += c++11

include($$PWD/../vendor/qompote.pri)
include($$PWD/../vendor/vendor.pri)
$$setBuildDir()

SOURCES += \
    $$PWD/model/Config.cpp \
    $$PWD/model/AuthorInfo.cpp \
    $$PWD/model/PackageInfo.cpp \
    $$PWD/model/Query.cpp \
    $$PWD/model/QuerySettings.cpp \
    $$PWD/model/RepositoryInfo.cpp \
    $$PWD/model/RequireInfo.cpp \
    $$PWD/model/TargetInfo.cpp \
    $$PWD/model/PriorityMode.cpp \
    $$PWD/model/BuildMode.cpp \
    $$PWD/model/IncludeMode.cpp \
    $$PWD/loader/ILoader.cpp \
    $$PWD/loader/FsLoader.cpp \
    $$PWD/loader/GitLoader.cpp \
    $$PWD/loader/HttpLoader.cpp \
    $$PWD/loader/MockLoader.cpp \
    $$PWD/loader/IRepository.cpp \
    $$PWD/loader/GitsRepository.cpp \
    $$PWD/loader/InqludeRepository.cpp \
    $$PWD/loader/RawFsRepository.cpp \
    $$PWD/accessor/GitWrapper.cpp \
    $$PWD/accessor/HttpWrapper.cpp \
    $$PWD/IQompoter.cpp \
    $$PWD/Qompoter.cpp \
    $$PWD/commandline.cpp \

HEADERS += \
    $$PWD/model/Config.h \
    $$PWD/model/AuthorInfo.h \
    $$PWD/model/PackageInfo.h \
    $$PWD/model/Query.h \
    $$PWD/model/QuerySettings.h \
    $$PWD/model/RequireInfo.h \
    $$PWD/model/RepositoryInfo.h \
    $$PWD/model/TargetInfo.h \
    $$PWD/model/PriorityMode.h \
    $$PWD/model/BuildMode.h \
    $$PWD/model/IncludeMode.h \
    $$PWD/loader/ILoader.h \
    $$PWD/loader/FsLoader.h \
    $$PWD/loader/GitLoader.h \
    $$PWD/loader/HttpLoader.h \
    $$PWD/loader/MockLoader.h \
    $$PWD/loader/IRepository.h \
    $$PWD/loader/GitsRepository.h \
    $$PWD/loader/InqludeRepository.h \
    $$PWD/loader/RawFsRepository.h \
    $$PWD/accessor/GitWrapper.h \
    $$PWD/accessor/HttpWrapper.h \
    $$PWD/IQompoter.h \
    $$PWD/Qompoter.h \
    $$PWD/commandline.h \

RESOURCES += \
    $$PWD/rsc/qompoter.qrc \

INCLUDEPATH += \
    $$PWD/model \
    $$PWD/loader \
    $$PWD/accessor \

!autotester {
    SOURCES += $$PWD/main.cpp
}
