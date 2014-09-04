Qompoter
================================

An attempt of dependency manager for Qt / C++. Because I am sick of managing each C++ piece of code separately!

Inspired by the well-known Composer PHP dependency manager.

The current version is not working yet. It will only be able to retrieve packages from the file system, or via a git repository on the file system. A lot have to be done to at least make it work:

* retrieve Git repository from a remote file system (e.g. Github)
* compile packages as shared libraries (with a local and global version)
* generate a vendor.pri file to use the packages in the project

Setup
--------------------------------

    mkdir build-qompoter
    cd build-qompoter
    qmake ../qompoter/qompoter.pro
    make
    sudo chmod u+x qompoter

Usage
--------------------------------

Copy paste the example qomposer.json file and run:

    ./qompoter install

License
--------------------------------

Distributed under the LGPL3 license.

If you have any ideas, critiques, suggestions or whatever you want to call it, please open an issue. I'll be happy to hear from you what you'd see in this lib. I think about all suggestions, and I try to add those that make sense.
