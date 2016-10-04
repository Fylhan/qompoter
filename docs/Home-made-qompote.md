What is this "qompote.pri" file?
========

The "qompote.pri" defines several new functions to be used in qmake ".pro" or ".pri" files, especially to help managing several architecture of compilation (x86, arm, ...). This file is included at the begining of the "vendor.pri" file.

The new function can be used into any ".pro" or ".pri" file once `include($$PWD/vendor/qompote.pri)` or `include($$PWD/vendor/vendor.pri)` is added in it.

## New qmake functions

### setLibPath()

Generate a lib path name depending of the OS and the arch. Export and return LIBPATH.

### setLibName(lib name[, lib version])

Will add a "d" at the end of lib name in case of debug compilation, and "-version" if provided. Export VERSION, export and return LIBNAME.

### getLibName(lib name)

Will add a "d" at the end of lib name in case of debug compilation, and "-version" if provided
Return lib name

### getCompleteLibName(lib name)

Will add a "d" at the end of lib name in case of debug  echo compilation, and "-version" if provided. Return lib name.

### setBuildDir()

Generate a build dir depending of OS and arch. Export MOC_DIR, OBJECTS_DIR, UI_DIR, TARGET, LIBS

### addSubdirs(subdirs,deps)

Adds directories to the project that depend on other directories
