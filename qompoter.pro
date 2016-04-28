TEMPLATE = subdirs
CONFIG += ordered

SUBDIRS += src \
    test

test.depends = src

OTHER_FILES += \
    $$PWD/.travis.yml \
    $$PWD/CMakeLists.txt \
    $$PWD/qompoter.json \
    $$PWD/README.md \
    $$PWD/changelogs.md \
    $$PWD/Doxyfile \
    $$PWD/docs/*.md \

include($$PWD/vendor/qompote.pri)
$$setBuildDir()

