TEMPLATE = subdirs
CONFIG += ordered

SUBDIRS += src \
    test

test.depends = src

OTHER_FILES += \
    $$PWD/.travis.yml \
    $$PWD/CMakeLists.txt \
    $$PWD/README.md \
    $$PWD/qompoter.json \
    $$PWD/changelogs.md \
    $$PWD/docs/*.md \
    $$PWD/Doxyfile \

include($$PWD/vendor/qompote.pri)
$$setBuildDir()

