Qompoter
================================

An attempt of dependency manager for Qt / C++. Because I am sick of managing each C++ piece of code separately!

Inspired by the well-known Composer PHP dependency manager.

The current version is still a work in progress. But still, you can:

* describe your dependencies in qomposer.json
* retrieve all these packages from a Git repository or a structured file system
* generate a vendor.pri file to include and use in your .pro file

A lot have to be done to make it really usable.

Installation
--------------------------------

Make the script file runnable, and move it to a place accessible in the PATH:

    chmod u+x qompoter.sh
    mv qompoter.sh /usr/bin/qompoter

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
			"anyother/test": "v1.0"
		},
		"repositories": {
			"qompotist" : "https://github.com"
		}
	}

Then, download and install dependencies listed in your qompoter.json using:

	qompoter

That's it! You can now include vendor.pri in the .pro file of your project, and include the dependencies that you required:

    CONFIG += solilog chartxy
    include(vendor/vendor.pri)

License
--------------------------------

Distributed under the LGPL3+ license.

If you have any ideas, critiques, suggestions or whatever you want to call it, please open an issue. I'll be happy to hear from you what you'd see in this lib. I think about all suggestions, and I try to add those that make sense.
