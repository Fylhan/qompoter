Packages
========

Two kinds of packages
---------------------
* **library**: Qompoter download the library , install it locally or globally, and create the relevant vendor.pri -> that's it! You are ready to work!
    * Yes but... the library compilation shall match your project: same compilator, same Qt version, same arch (32bit / 64 bit), same OS, ...
	* Still useful for a company scenario: someone build all required libraries and make them available in a private / online repository
* **Source files** compiled with your projects: Qompoter download the source files and create the relevant vendor.pri -> the packages will be compiled with your project. You are ready to work!

Create a library package
---------------------

Your package should contain:

* **include** A folder "include" containing all the public headers
* **lib_** One or several folders containing the library itself (*.a, *.so, *.dll)
	* For Linux : lib_linux_32 and lib_linux_64
	* For Windows : lib_windows_32 and lib_windows_64
	* As you can see, there is no way to define the compilator (GCC, Clang, ...), this has to be done
* **qompoter.pri** Your package should contain a qompoter.pri file describing how to add it in another project
* **qompoter.json** Your package may contain a qomposer.json file, it is useful to describe it

Example of qompoter.pri file for a library package:

	projectName {
		LIBNAME = projectName
		IMPORT_INCLUDEPATH = $$PWD/projectName/include
		IMPORT_LIBPATH = $$PWD/$$LIBPATH
		INCLUDEPATH += $$IMPORT_INCLUDEPATH
		LIBS += -L$$IMPORT_LIBPATH -l$$getLibName($${LIBNAME})
	}

Create a source package
---------------------

Your package should contain:

* All the files of the package. Generally, main files are in a "src" folder, and unit test files are in a "test" folder.
* **qompoter.pri** Your package should contain a qompoter.pri file describing how to add it in another project
* **qompoter.json** Your package may contain a qomposer.json file, it is useful to describe it

A common structure is:

* src
	* files...
	* main.cpp
	* src.pri
* test
	* files...
	* main.cpp
	* test.pri
* qompoter.pri
* qompoter.json
* README.md
	
Example of qompoter.pri file for a source package:

	projectName {
	   SOURCES += \
		    $$PWD/projectName/src/main.cpp \
		    $$PWD/projectName/src/File1.cpp \
		    $$PWD/projectName/src/folder1/File2.cpp \
		 
	    HEADERS += \
		    $$PWD/projectName/src/File1.h \
		    $$PWD/projectName/src/folder1/File2.h \

	    INCLUDEPATH += \
		    $$PWD/projectName \
		    $$PWD/projectName/src/folder1
	}
