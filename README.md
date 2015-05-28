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

A lot have to be done to make it really usable.

Build
--------------------------------

To build this project, Qt5 is required. You may also need to update your PATH to compile in command line:

	export PATH=/opt/Qt/5.3/gcc/bin:$PATH
	export QTDIR=/opt/Qt/5.3/gcc

	mkdir build-qompoter && cd build-qompoter
	qmake ../qompoter/qompoter.pro
	make

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
			"trialog/solilog": "v1.0",
			"trialog/gpslib": "v1.1",
			"trialog/octavor": "v0.8",
			"trialog/qextserialport": "v1.2rc",
			"trialog/tcanp": "v1.6.7-lib"
		},
		"require-dev": {
			"trialog/autotester": "v1.0"
		}
	}

Then, download and install dependencies listed in your qompoter.json using:

	qompoter install
	qompoter make

That's it! You can now include vendor.pri in the .pro file of your project, and include the dependencies that you required:

	CONFIG += solilog chartxy
	include(vendor/vendor.pri)

Roadmap
--------------------------------

* Compile packages as shared libraries (with a local and global version), or as source project
* Manage version numbers
* Generate better vendor.pri file (from template) to use the packages in the project
* Better support and description of repositories:
	* structure
	* how to add package in it
* Forget bash and go to C++/Qt
* Better support of Git repositories
* Manage several repositories : one in local, one on Squeak, and some online (Github, ...)
* Clarify command line
* Add qompoter update: using a qompoter.lock file
* Don't copy/paste lib and headers: in vendor.pri link to existing files
* Add qompoter install --local: which copy/paste lib and headers
* Use QT += package instead of CONFIG which leverage the usage of include(vendor.pri)
* Link with inqlude
* Link with CPM (?)
* Special cases for Qt Plugins
* Better support of qompoter.json
* JSON schema for qompoter.json

Documentation
--------------------------------

### Two kinds of packages
* '''Library''': Qompoter download the library , install it locally or globally, and create an adapted vendor.pri -> you just need to use it
	* Yes but... the library compilation shall match your project: same compilator, same Qt version, same arch (32bit / 64 bit), same OS, ...
	* Still useful for company scenarii: someone build all required libraries and make them available in a private / online repositories
* '''Source files''' compiled with your projects: Qompoter download the source files and create an adapted vendor.pri -> use it and the packages will be compiled with your project

Related projects
--------------------------------
* [inqlude ](http://inqlude.org/) Listing of existing Qt libraries
* [CPM](https://github.com/iauns/cpm) C++ Package Manager using CMake

License
--------------------------------

Distributed under the LGPL3+ license.

If you have any ideas, critiques, suggestions or whatever you want to call it, please open an issue. I'll be happy to hear from you what you'd see in this lib. I think about all suggestions, and I try to add those that make sense.