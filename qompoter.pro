TEMPLATE = subdirs
CONFIG += ordered
CONFIG += runtest # Uncomment to build also tests and to run them

SUBDIRS += src
runtest{
    message(Compile unit tests)
    SUBDIRS += test
    test.depends = src
}

OTHER_FILES += \
    $$PWD/CMakeLists.txt \
    $$PWD/README.md \
    $$PWD/qompoter.json \
    $$PWD/changelogs.md \
    $$PWD/docs/*.md \

include($$PWD/vendor/qompote.pri)
$$setBuildDir()
message(Qompoter build folder is $$OBJECTS_DIR)

