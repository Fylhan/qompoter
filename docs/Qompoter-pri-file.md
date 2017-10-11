Qompoter.pri File
========

The "qompoter.pri" file provides a Qt description of the files of the package. It allows Qompoter to generate a "vendor.pri" to be included in a project to easily use the required dependencies. The "vendor.pri" contains the list of files of all required packages. Furthermore, the "vendor.pri" add the "vendor" directory and each package directory to the qmake "INCLUDEPATH" variable.

Structure
--------------

In Qompoter, the convention is to be able to include a package using the qmake "CONFIG" variable and the name of the package. This involves to embed the list of files, and all the other stuffs useful to use the package, into a "project-name" variable, for a source package, or "project-name-lib" variable, for a library package.
Here is an example of a package "project-name" containing two files, "A" and "B", with the "B" file into a "C" directory. This package depends of another package "other-package".

```qmake
project-name {
    HEADERS += \
        $$PWD/project-name/C/B.h \
        $$PWD/project-name/A.h

    SOURCES += \
        $$PWD/project-name/C/B.cpp \
        $$PWD/project-name/A.cpp \

    INCLUDEPATH += $$PWD/project-name/C

    CONFIG += other-package
}
```

For a library package, the best practice is to let the end-user choose between source mode or library mode, and therefore to provide both "project-name" and "project-name-lib" blocks (see the example below).

Once running `qompoter install`, the end-user just has to add the following into its ".pro" file to be able to use the new package:

```qmake
CONFIG += yoda-lib # or "yoda" to use the source version
include($$PWD/vendor/vendor.pri)
```

Example
--------------

Here is an example of "qompoter.pri" file for the project "yoda". As you can see, the end-user have the choice to use the library or the source version.

```qmake
yoda-lib {
    LIBNAME = yoda
    IMPORT_INCLUDEPATH = $$PWD/yoda/include
    IMPORT_LIBPATH = $$PWD/$$LIBPATH
    INCLUDEPATH += $$IMPORT_INCLUDEPATH
    LIBS += -L$$IMPORT_LIBPATH -l$$getLibName($${LIBNAME})
}

yoda {
    HEADERS += \
        $$PWD/yoda/force/force.h \
        $$PWD/yoda/yoda.h

    SOURCES += $$PWD/yoda/force/force.cpp

    INCLUDEPATH += $$PWD/yoda/force
}
```
