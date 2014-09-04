DEPENDPATH += $$PWD
INCLUDEPATH += $$PWD $$PWD/.

# Configurator
SOURCES += \
    $$PWD/trialog/configurator/ConfigFileManager.cpp \

HEADERS += \
    $$PWD/trialog/configurator/ConfigFileManager.h \

INCLUDEPATH += $$PWD/trialog/configurator \

# Test-engine
RUN_TESTS{
    QT += testlib
    CONFIG += console
    CONFIG -= app_bundle

    SOURCES += $$PWD/trialog/test-engine/AutoTestRunner.cpp \

    HEADERS += $$PWD/trialog/test-engine/AutoTestRunner.h \
        $$PWD/trialog/test-engine/IUnitTestCase.h \

    INCLUDEPATH += $$PWD/trialog/test-engine \
        $$PWD/trialog/test-engine/testcase \
}

