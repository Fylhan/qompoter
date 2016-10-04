Packages
========

Packages are the back-bone of Qompoter and, actually, of any dependency manager. Most of your projects must have dependencies to other projects, right? These dependencies are "packages". Your projects requires these packages to work, and this is the goal of Qompoter to help you find and install easily these packages.
But what is a package? Actually any project can be a package and be included in other projects. A package is just a normal project, but it can be ever better and easier to be used in other projects if it is provided with some useful stuffs like "qompoter.json" and "qompoter.pri" files.

To know how to define the required packages of a project, see [Qompoter file](Qompoter-json-file.md), but for now let's discuss about how to create packages.

Two Kinds of Packages
---------------------

In Qompoter, because it targets C++/Qt, there are two kinds of packages: library and source packages.

### **library** package

Qompoter download the library, install it locally in the "vendor" dir, and create the relevant "vendor.pri" file -> that's it! You are ready to work!

Ok but... it works only if the library compilation match your project's target: same compilator, same Qt version, same architecture (x86, x64, arm ...), same OS. This implies that someone has compiled the library for your target and has made it available to you.

This is useful in many cases, especially for teams using continuous integration: the continuous integration system build all the required libraries for all targets and make them available in a private local or online repository.

### **source** package

Qompoter download the source files into the "vendor" dir, creates the relevant "vendor.pri" file -> the packages will be compiled with your project. You are ready to work!


How to Create a Package?
---------------------

### Creating a Library Package

A library package should contain:

* **include**: the "include" directory shall contain all the public headers (*.h files).
* **lib_<platform>**: one or several directories containing the library itself (*.a, *.so, *.dll).
    * For Linux on x86: lib_linux_32 and lib_linux_64
    * For Linux on arm: lib_linux_gnueabi-arm
    * For Windows: lib_windows_32 and lib_windows_64
    * As you can see, there is no way to define the compilator yet (GCC, Clang, ...), this has to be done.
* **qompoter.pri**: the package should contain a "qompoter.pri" file describing how to include the package into another project. This file will be added to the "vendor.pri" file.
* **qompoter.json**: the package should contain a "qomposer.json" file describing the project and its dependencies.

Example of "qompoter.pri" file for a library package:

    projectName-lib {
        LIBNAME = projectName
        IMPORT_INCLUDEPATH = $$PWD/projectName/include
        IMPORT_LIBPATH = $$PWD/$$LIBPATH
        INCLUDEPATH += $$IMPORT_INCLUDEPATH
        LIBS += -L$$IMPORT_LIBPATH -l$$getLibName($${LIBNAME})
    }

### Creating a Source Package

A source package should contain:

* All the files of the package. Generally, main files are in a "src" directory, and unit test files are in a "test" directory.
* **qompoter.pri**: the package should contain a "qompoter.pri" file describing how to include the package into another project. This file will be added to the "vendor.pri" file.
* **qompoter.json**: the package should contain a "qomposer.json" file describing the project and its dependencies.

A common structure is:

* src
    * files...
    * main.cpp
    * src.pro
* test
    * files...
    * main.cpp
    * test.pro
* app.pro
* qompoter.pri
* qompoter.json
* README.md

Example of "qompoter.pri" file for a source package:

    projectName {
        HEADERS += \
            $$PWD/projectName/src/File1.h \
            $$PWD/projectName/src/folder1/File2.h \
            
        SOURCES += \
            $$PWD/projectName/src/main.cpp \
            $$PWD/projectName/src/File1.cpp \
            $$PWD/projectName/src/folder1/File2.cpp \
            
        INCLUDEPATH += \
            $$PWD/projectName \
            $$PWD/projectName/src/folder1
    }


Read more about how to create a package and list its dependencies by learning [how to create a Qompoter.json file](Qompoter-json-file.md) and the related [Qompoter.pri file](Qompoter-pri-file.md).
