Qompoter
================================

An attempt of dependency manager for Qt / C++, because I am sick of managing each C++ piece of code separately!

[![Build Status](https://travis-ci.org/Fylhan/qompoter.svg)](https://travis-ci.org/Fylhan/qompoter)

The current version is still a work in progress, a lot have to be done to make it really usable. Still, you can:

* describe in a qomposer.json file your dependencies
* search and retrieve the own dependencies of your selected dependencies
* retrieve all these packages from file system or via a Git repository
* generate a vendor.pri file to be included and used in your .pro file

Requirements
--------------------------------

* Git
* Linux, should also work on Mac or Windows (Cygwin or Msys command line)

Build
--------------------------------

To build this project, >= C++11 and >= Qt 5.4 are required. Please run, something like:

    ./qompoter.sh
    mkdir build-qompoter-qmake && cd build-qompoter-qmake
    qmake ../qompoter/qompoter.pro
    make

You may need to update your PATH to compile in command line, for example:

    export PATH=/opt/Qt/5.3/gcc/bin:$PATH
    export QTDIR=/opt/Qt/5.3/gcc

Installation
--------------------------------

Make Qompoter runnable, and move it to a place accessible in the PATH:

    chmod u+x qompoter
    mv qompoter /usr/bin/qompoter

Usage
--------------------------------

In your project repository, create a qompoter.json file:

    {
        "name": "fylhan/qompoter",
        "description": "Qompoter, a dependency manager for C++/Qt.",
        "keywords": ["Qt", "C++"],
        "authors": [
            {
                "name": "Fylhan",
                "homepage": "fylhan.la-bnbox.fr"
            }
        ],
        "require": {
            "qextserialport/qextserialport": "1.2rc"
        },
        "require-dev": {
            "another/package": "v1.0"
        },
        "repositories": [
            {
                "type": "gits",
                "url": "https://github.com"
            }
        ]
    }

Then download dependencies listed in your qompoter.json using:

    qompoter install

That's it! You can now include vendor.pri in the .pro file of your project, and include the dependencies that you required:

    CONFIG += qextserialport package
    include($$PWD/vendor/qompote.pri)
    include($$PWD/vendor/vendor.pri)

Roadmap
--------------------------------

* [Ok] Forget Bash and go to C++/Qt
* [In progress] Add documentation
* [In progress] Manage several repositories : using a structured filesystem, custom repo, and some online (Github, ...)
* [In progress] Better support of Git repositories (availability of the version)
* Manage version number: >=1.0, 1.0.*
* Describe and implement a "Packagist" like server for Qompoter
* Clarify command line
* Add qompoter update: using a qompoter.lock file
* Don't copy/paste lib and headers: in vendor.pri link to existing files
* Add qompoter install --local: which copy/paste lib and headers
* Use QT += package instead of CONFIG which leverage the usage of include(vendor.pri)
* [In progress] Link with inqlude
* Link with CPM (?)
* Special cases for Qt Plugins
* [In progress] Support CMake
* Check Windows support
* [In progress] Better support of qompoter.json
* [In progress] JSON schema for qompoter.json
* Add security by verifying hash keys
* Compile packages as shared libraries (with a local and global version), or as source project

Documentation
--------------------------------

* [Concept of packages](docs/Packages.md)
* [How to create a Qompoter file?](docs/Qompoter-file.md)
* [How to create a Qompoter repository?](docs/Repositories.md)
* [Command line interface](docs/Command-line.md)

Releases
--------------------------------
Qompoter is released under 2 versions:

* The current version, called "qompoter", aims to be a complete implementation in C++/Qt.
* A proof-of-concept, called "qompoter-bash", a simple Bash implementation fitted for basic usage, is developed in the meantime. Useful to kickoff the project without involving big development, this version targets basic usage and its development may end once a stable enough version is released.

In order to simplify numerotation, v0.1 to v0.6 are reserved for "qompoter-bash". Therefore, the first "qompoter" version is v0.7.

Related projects
--------------------------------

* [inqlude ](http://inqlude.org/) Listing of existing Qt libraries
* [CPM](https://github.com/iauns/cpm) C++ Package Manager using CMake

License
--------------------------------

* Qompoter is distributed under the LGPL3+ license.

Please feel free to contribute.

If you have any ideas, critiques, suggestions or whatever you want to call it, please open an issue. I'll be happy to hear from you what you'd see in this tool. I think about all suggestions, and I try to add those that make sense.
