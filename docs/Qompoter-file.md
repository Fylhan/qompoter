Qompoter.json file
========

Basic Example
--------------
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
		"target": {
			"compiler": "gcc",
			"os": "linux",
			"arch": "32",
			"makefile": "qmake"
		},
		"require": {
			"qt": "5.4",
			"cpp": "11",
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

Parameter List
--------------
### require
#### Versions
* Version number: searched on the folder name or a versioning system tag, branch or commit number (e.g. v1.0, 456dgfg88)
* Suffixes:
	* "dev-": Target a versioning system branch (e.g. dev-master)
* Prefixes:
	* "-lib": Search only a library
	* "-src": Search only source files
	* By default, without any prefix, Qompoter is searching for a library and use the source if this latter does not exist

### require-dev
Same as "require" but only downloaded in dev mode.

