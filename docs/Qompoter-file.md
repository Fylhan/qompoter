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
                "qextserialport/qextserialport": "1.2rc"
            },
            "require-dev": {
                "another/package": "v1.0"
            },
            "repositories": [
                {
                    "type": "git",
                    "url": "https://github.com"
                }
            ]
    }

Parameter List
--------------
### target
*Not available yet*

The target field specifies the configuration of the current package: compilation, OS, arch and make tool.

### require
The require field is a set of key / value to list all dependencies, and their version, of a project. Each of these listed packages will be downloaded by Qompoter.

* The "value" describes a package by a vendor name (optional, a company name for example) and a project name.
* The "key" describes the version of the package. This latter can be a versioning system tag, branch or commit number (e.g. v1.0, 456dgfg88), or it can be a folder name in the structured file system repository. Typically a structured file system repository contains: "vendor name/project name/v1"..."vendor name/project name/v2". You need to follow these rules for the version:
    * Suffixes:
        * "dev-": Target a versioning system branch (e.g. dev-master)
    * Prefixes:
        * "-lib": Search only a library
        * "-src": Search only source files
        * By default, without any prefix, Qompoter is searching for a library and use the source if this latter does not exist

### require-dev
Same as "require" but only downloaded in dev mode.

### repositories
The repositories field is a set of key / value to list all available repositories. Nowadays, only one url is used.

In the example above, packages will be downloaded in Github using: `https://github.com/vendor/project name"`.

It is also possible to specify a path to a directory in your file system, [specialy structured for Qompoter usage](Repositories.md).

Note that you can also specifying this in the [command line](Command-line.md) using the "--repo" parameter: `qompoter --repo https://github.com`.


