Qompoter.json File
========

The "qompoter.json" file provides a structured description of a package and list its required dependencies to others packages. Its read by Qompoter once running `qompoter install` to retrieve the list of required packages and downloads them from repositories.

Note: Yes, this is similar to the "composer.json" file of Composer, "packages.json" of npm, or even the "maven.xml" of Maven.

Examples
--------------

Here is a basic example of "qompoter.json" file for a project called "a-new-hope" with two dependencies "luke" and "yoda".

```json
{
    "name": "george/a-new-hope",
    "description": "Three things remains: faith, hope and love.",
    "require": {
        "young/luke": "v0.1",
        "young/leia": "v0.5"
    },
}
```

Here is a more complex example for a project called "return-of-the-jedi". It has three dependencies "luke", "leia" and "yoda" and there is a specific repository URL to download "leia" and "yoda" from Github. Another dependency "han" is listed as required only for development and not to be used in production, or when the package is required by another one.

```json
{
    "name": "george/return-of-the-jedi",
    "description": "Three things remains: faith, hope and love.",
    "keywords": ["Jedi", "Force", "Faith", "Hope", "Love"],
    "authors": [
        {
            "name": "George Lucas",
            "homepage": "https://starwars.com"
        }
    ],
    "require": {
        "young/luke": "v0.2.1-beta",
        "young/leia": "v0.5-lib",
        "old/yoda": "dev-master"
    },
    "require-dev": {
        "milenium-falcon/han": "v1.0"
    },
    "repositories": {
        "old/yoda" : "https://github.com",
        "young/leia": { "url": "https://raw.githubusercontent.com/young/leia/fdf464df84fs9g8/v0.5-lib.tar.gz" }
    }
}
```


Main Parameters
--------------

Here is a short list of the main parameters for the "qompoter.json" file. For most use cases, you do not need more!

Note: in the following lines, by "CVS" meant all control versioning systems like Git, SVN, Mercurial ... even if only Git is supported by Qompoter at the moment.

### name

Logical name of the package composed of a vendor name (user name, company name or group name, it's up to you) and a project name: vendor/project.

The vendor name is useful to avoid duplication in the project name. Thanks to Github, we generally all use our user name as vendor name for personal projects.

### description

Quick description of the package. It helps understanding what is it made for.

### require

The require field is a set of key / value to list all required dependencies to other packages, and of course the version of these packages. Each of these listed packages will be downloaded by Qompoter.

The __"key"__ describes a package by a vendor name (user name, company name or group name, it's up to you) and a project name: vendor/project. Normaly it should uniquely identify the package.

The __"value"__ describes the version of the package. This latter can be a version number (_v1.0, v2.2-RC1, v1.\*_), a CSV branch (_dev-master, dev-tcpversion_) or a commit number (_#456dgfg88_). As you can see, you need to use the prefix "dev-" for CSV branches and "#" for CSV commit numbers.

By convention, a [library package](Packages.md#two-kinds-of-packages) is suffixed with "-lib", otherwise it is a source package.

Here is an example of "qompoter.json" file with several types of version numbers.

```json
{
    "name": "george/lucas",
    "require": {
        "young/luke": "v0.1",
        "young/leia": "v0.5-RC2",
        "young/han": "v1.*",
        "robot/R2D2": "#456dgfg88",
        "robot/C3PO": "dev-mybranch",
        "wookie/chewie": "dev-master",
        "old/obiwan": "v1.*-lib",
        "old/yoda": "v900.0-lib"
    },
}
```

Take a look at the [Qompoter repository structure](Repositories.md) structure to understand better this package version stuff.

### require-dev

Same as "require" but only downloaded in "dev" mode and for the main package (i.e. not for recursive dependency). Qompoter is by default in "dev" mode, but can be used with "--no-dev".

List here packages that are only needed for development, like unit testing tools, parsers, things like that.

### repositories

The repositories field is a set of key / value to list specific repository to be used for each package. This allows to override the default repository path for a package, or even provide a defined URL to download the package.

Let me show again the "qompoter.json" example:

```json
{
    "name": "george/return-of-the-jedi",
    "description": "Three things remains: faith, hope and love.",
    "keywords": ["Jedi", "Force", "Faith", "Hope", "Love"],
    "authors": [
        {
            "name": "George Lucas",
            "homepage": "https://starwars.com"
        }
    ],
    "require": {
        "young/luke": "v0.2.1-beta",
        "young/leia": "v0.5-lib",
        "old/yoda": "dev-master"
    },
    "require-dev": {
        "milenium-falcon/han": "v1.0"
    },
    "repositories": {
        "old/yoda" : "https://github.com",
        "young/leia": { "url": "https://raw.githubusercontent.com/young/leia/fdf464/v0.5-lib.tar.gz" }
    }
}
```

With this "qompoter.json" file:

* "old/yoda" package will be downloaded in Github using: `https://github.com/<vendor name>/<project name>"`, which gives `https://github.com/old/yoda`
* "young/leia" package will be downloaded using directly the given URL "https://raw.githubusercontent.com/young/leia/fdf464/v0.5-lib.tar.gz".

It is also possible to specify a path to a directory in your file system, [especially structured for Qompoter usage](Repositories.md).

Note that you can also specifying this for all packages in the [command line](Command-line.md) using the "--repo" parameter: `qompoter --repo https://github.com`. At the moment, there is no way to define a repository path for each package in command-line, this is only possible using the "qompoter.json" file.


Other Parameters
--------------

Here is a complete list of the other available parameters for the "qompoter.json" file. It is definitely too short and will be increased in the future to enable new use cases.

### authors

List the package's authors, especially their names ("name"), their emails ("email") or eventually their Web page ("homepage").
