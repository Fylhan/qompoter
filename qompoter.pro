TARGET = qompoter
TEMPLATE = app
QT += core network script

### Configuration
#DEFINES += RUN_TEST # Uncomment to run unit tests

### Dependencies
include( vendor/vendor.pri )

### Project Files
include( src/src.pri )
RUN_TEST {
    message(Compile unit tests)
    include( test/test.pri )
}

### Builder
CONFIG += ordered
SUBDIRS += builder

win32-cross-mingw {
        MOC_DIR	 = build_win32
        OBJECTS_DIR = build_win32
        UI_DIR	  = build_win32
}
else:unix {
        MOC_DIR	 = build_linux
        OBJECTS_DIR = build_linux
        UI_DIR	  = build_linux
}
