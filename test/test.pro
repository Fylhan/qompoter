DEPENDPATH += $$PWD
INCLUDEPATH += $$PWD $$PWD/. $$PWD/..

CONFIG += autotester
include(../src/src.pro)

SOURCES += \
    $$PWD/TestRunner.cpp \
#    $$PWD/test-case/UnitTest.cpp \

HEADERS += \
#    $$PWD/test-case/UnitTest.h \
