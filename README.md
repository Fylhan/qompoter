Qompoter
================================

An attempt of dependency manager for Qt / C++, because I am sick of managing each C++ piece of code separately!


[![Build Status](https://travis-ci.org/Fylhan/qompoter.svg?branch=master)](https://travis-ci.org/Fylhan/qompoter)

The current version is still a work in progress, a lot have to be done to make it really usable. Still, you can:

* describe your dependencies in a "qomposer.json" file
* search and retrieve all dependencies (also recursively for sub-dependencies) from the [inqlude](https://inqlude.org/) repository, a Git repository (a local one or something like Github) or a [structured file system](docs/Repositories.md)
* generate qompote.pri and vendor.pri files to be included and used in your .pro file for Qt

Requirements
--------------------------------

* Bash
* Git, sed, zip

Works on Linux and Windows (using Git bash). It should also work on Mac and more widely on Windows (Cygwin or Mysys command line) but I did not test it yet.

Installation
--------------------------------

Download Qompoter and make the script file runnable, and move it to a place accessible in the `PATH`:

	wget https://raw.githubusercontent.com/Fylhan/qompoter/f5ede63cb54586fc0388a95da3c7cab7ee559f1f/qompoter.sh -O qompoter.sh
	chmod u+x qompoter.sh
	mv qompoter.sh /usr/bin/qompoter

Usage
--------------------------------

In your project, create a qompoter.json file:

	{
		"name": "fylhan/hope",
		"description": "Three things remains: faith, hope and love.",
		"keywords": ["Qt", "C++"],
		"authors": [
			{
				"name": "Fylhan",
				"homepage": "fylhan.la-bnbox.fr"
			}
		],
		"require": {
			"fylhan/platphorm": "dev-master",
			"fylhan/posibrain": "v0.*"
		},
		"require-dev": {
			"cp/fylhan": "v1.0"
		},
		"repositories": {
			"fylhan/platphorm" : "https://github.com",
			"fylhan/posibrain" : "https://github.com"
		}
	}

Then, download and install dependencies listed in your `qompoter.json` using:

	qompoter install

*For more information about the command line options, use `qompoter --help`.*

That's it! You can now include `vendor.pri` in the `.pro` file of your project, and include the dependencies that you required:

	CONFIG += platphorm posibrain fylhan
	include(vendor/vendor.pri)

Documentation
--------------------------------

* [Concept of packages](docs/Packages.md)
* [How to create a Qompoter file?](docs/Qompoter-file.md)
* [How to create a Qompoter repository?](docs/Repositories.md)
* [Command line interface](docs/Command-line.md)

Releases
--------------------------------
Qompoter is released under 2 versions:

* The current version is a proof-of-concept developed in bash, useful to kickoff the project without involving big development. It is actually working quite well and is now more than just a proof-of-concept.
* A more complete implementation has been started in C++/Qt and should provide more portability and robustness if the project grows. The development of this version is currently paused because bash is actually suffisant at the moment.

In order to simplify numerotation, v0.1 to v0.6 are reserved for "qompoter.sh". Therefore, the first "qompoter" (C++/Qt) version is v0.7. This may change in the future.

There is a previsional [roadmap](TODO.md)

Similar projects
--------------------------------

* [inqlude](http://inqlude.org/) Listing existing Qt libraries
* [QPM](https://github.com/Cutehacks/qpm) Qt package manager
* [CPM](https://github.com/iauns/cpm) C++ package manager using CMake
* [Conan](https://github.com/conan-io/conan) C/C++ distributed package manager
* [QtPods](https://github.com/qt-pods/qt-pods) Unify packaging of fragment of Qt codes

License
--------------------------------

* Qompoter is distributed under the [LGPL3+](LICENSE) license. *Therefore, you can freely use it in any projects, even closed one. Just keep in mind that if you modify Qompoter, you shall provide these updates as open source. Thanks!*
* Qompoter is using [JSON.sh](https://github.com/dominictarr/JSON.sh) under the MIT and Apache 2 license. Qompoter unit tests are also based on the JSON.sh architecture.

Please feel free to contribute.

If you have any ideas, critiques, suggestions or whatever you want to call it, please open an issue. I'll be happy to hear from you what you'd see in this tool. I think about all suggestions, and I try to add those that make sense.
