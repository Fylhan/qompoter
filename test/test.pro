DEPENDPATH += $$PWD
INCLUDEPATH += $$PWD $$PWD/. $$PWD/..

CONFIG += autotester
include(../src/src.pro)
include(../common.pri)
$$setBuildDir()

SOURCES += \
    $$PWD/TestRunner.cpp \
    $$PWD/test-case/QompoterTest.cpp \

HEADERS += \
    $$PWD/test-case/QompoterTest.h \

VALIDATION_FILES = $$files($$PWD/qompoter.json)
copyValidationFiles.name = Copy test validation data
copyValidationFiles.input = VALIDATION_FILES
copyValidationFiles.output = $$DESTDIR/${QMAKE_FILE_BASE}${QMAKE_FILE_EXT}
copyValidationFiles.commands = ${COPY_FILE} ${QMAKE_FILE_IN} ${QMAKE_FILE_OUT}
copyValidationFiles.CONFIG += no_link target_predeps
QMAKE_EXTRA_COMPILERS += copyValidationFiles
