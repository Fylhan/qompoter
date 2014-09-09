Qompoter
================================

An attempt of dependency manager for Qt / C++. Because I am sick of managing each C++ piece of code separately!

Inspired by the well-known Composer PHP dependency manager.

The current version is still a work in progress. But still, you can:

* describe in a qomposer.json file your dependencies
* search and retrieve the own dependencies of your selected dependencies
* retrieve all these packages from file system, or via a Git repository
* compile and deploy theses packages as shared libraries
* generate a vendor.pri file to include and use in your .pro file

A lot have to be done to make it really usable:

* compile packages as shared libraries (with a local and global version), or as source project
* search for recursive packages also for Git repositories
* manage version numbers
* generate better vendor.pri file (from template) to use the packages in the project

Setup
--------------------------------

To build this project, Qt5 is required. And you may need to update your PATH to compile in command line:

    export PATH=/opt/Qt/5.3/gcc/bin:$PATH
    export QTDIR=/opt/Qt/5.3/gcc

    mkdir build-qompoter
    cd build-qompoter
    qmake ../qompoter/qompoter.pro
    make

Usage
--------------------------------

Make the exec file runnable, copy paste the sample qomposer.json file in your build repository:

    sudo chmod u+x qompoter
    cp ../qompoter/qompoter.json .

and install and deploy your required dependencies easily with Qompoter:

    ./qompoter install
    ./qompoter make

That's it! You can now include vendor.pri in the .pro file of your project, and include the dependencies that you required:

    CONFIG += solilogger chartxy
    include(vendor/vendor.pri)

License
--------------------------------

Distributed under the LGPL3+ license.

If you have any ideas, critiques, suggestions or whatever you want to call it, please open an issue. I'll be happy to hear from you what you'd see in this lib. I think about all suggestions, and I try to add those that make sense.
