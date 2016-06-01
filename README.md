Qompoter
================================

An attempt of dependency manager for Qt / C++, because I am sick of managing each C++ piece of code separately!

*Inspired by the well-known Composer PHP dependency manager.*

The current version is still a work in progress, a lot have to be done to make it really usable. Still, you can:

* describe dependencies in qomposer.json
* retrieve all these packages from a Git repository or a structured file system
* generate a vendor.pri file to be included and used in a .pro file

Requirements
--------------------------------

* Bash
* Git
* sed
* zip is recommended

Works on Linux, and should also work on Mac or Windows (Cygwin or Mysys command line)

Installation
--------------------------------

Make the script file runnable, and move it to a place accessible in the PATH:

    chmod u+x qompoter.sh
	mv qompoter.sh /usr/bin/qompoter-bash

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
			"qextserialport/qextserialport": "1.2rc"
		},
		"require-dev": {
			"another/package": "v1.0"
		},
		"repositories": {
			"qompotist" : "https://github.com"
		}
	}

Then, download and install dependencies listed in your qompoter.json using:

	qompoter-bash install

That's it! You can now include vendor.pri in the .pro file of your project, and include the dependencies that you required:

	CONFIG += solilog chartxy
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

* The current version is a proof-of-concept called "qompoter-bash", a simple Bash implementation fitted for basic usage. Useful to kickoff the project without involving big development, this version targets basic usage and its development may end once a stable enough version is released.
* The main "qompoter" version is a more complete implementation in C++/Qt. Developped in the mean time as "qompoter-bash", the "qompoter" version aims to provide more features and flexibilities.

In order to simplify numerotation, v0.1 to v0.6 are reserved for "qompoter-bash". Therefore, the first "qompoter" version is v0.7.

License
--------------------------------

* Qompoter is distributed under the LGPL3+ license.
* Qompoter is using [JSON.sh](https://github.com/dominictarr/JSON.sh) under the MIT and Apache 2 license.

Please feel free to contribute.

If you have any ideas, critiques, suggestions or whatever you want to call it, please open an issue. I'll be happy to hear from you what you'd see in this tool. I think about all suggestions, and I try to add those that make sense.
