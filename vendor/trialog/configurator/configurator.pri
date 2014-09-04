DEPENDPATH += $$PWD
INCLUDEPATH += $$PWD $$PWD/.

### Logger
# Home-made
SOURCES += $$PWD/logger/Logger.cpp \
        $$PWD/logger/LoggerConfiguration.cpp \

HEADERS += $$PWD/logger/Logger.h \
        $$PWD/logger/LoggerConfiguration.h \

INCLUDEPATH += $$PWD/logger \

#QsLog
include(logger/QsLog/QsLog.pri)


### JSON
SOURCES += $$PWD/config/JsonHelper.cpp \
        $$PWD/config/ConfigFileManager.cpp \

HEADERS += $$PWD/config/JsonHelper.h \
        $$PWD/config/ConfigFileManager.h \

INCLUDEPATH += $$PWD/config \


### Screenshot
SOURCES += $$PWD/ScreenshotManager.cpp \

HEADERS += $$PWD/ScreenshotManager.h \





