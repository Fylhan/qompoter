DEPENDPATH += $$PWD
INCLUDEPATH += $$PWD $$PWD/. $$PWD/..

SOURCES += $$PWD/main.cpp \
    $$PWD/model/Config.cpp \
    $$PWD/model/AuthorInfo.cpp \
    $$PWD/model/RequireInfo.cpp \
    $$PWD/model/PackageInfo.cpp \
    $$PWD/model/RepositoryInfo.cpp \
    $$PWD/model/Query.cpp \
    $$PWD/loader/FsLoader.cpp \
    $$PWD/loader/GitLoader.cpp

HEADERS += $$PWD/model/Config.h \
    $$PWD/model/AuthorInfo.h \
    $$PWD/model/RequireInfo.h \
    $$PWD/model/PackageInfo.h \
    $$PWD/model/RepositoryInfo.h \
    $$PWD/model/Query.h \
    $$PWD/loader/ILoader.h \
    $$PWD/loader/FsLoader.h \
    $$PWD/loader/GitLoader.h

OTHER_FILES += $$PWD/../qompoter.json \
    $$PWD/../README.md \

INCLUDEPATH += $$PWD/model \
    $$PWD/loader \

