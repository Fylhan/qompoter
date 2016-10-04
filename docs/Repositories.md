Repositories
============

As explained in "[How to create a qompoter.json file](Qompoter-json-file.md)", a package is identified by its vendor name, its project name, and by a version number. E.g. *fylhan/qompoter/v1.0.0*.
A package can be available in library mode or source mode (see "[Notion of packages](Packages.md)").
The last important piece of information about a package, is its download location (i.e. an URL) and therefore how to download it (copy from the file system, download from the Web, clone a Git repository...). This is the purpose of a repository: listing packages and the means to download them.

The C++ and Qt environments are very big, there are lot of libraries and projects into the wild, and the only idea of having one repository to rule them all (*3 Rings for the Elven-kings under the sky, 7 for the Dwarf-lords in their halls of stone, and so one*) is just crazy and kind of stupid. Yes, this is what is done for the PHP environment, or the Node.js one, but they do not have the same history. Not to mention the multiplicity of target platforms or compilation environments in C++... This is real life, this is history and one of the strenght of these environments.

That is why a key concept of Qompoter is to be able to handle several types of repositories:

* Structured one like Qompotist-fs (defined specifically for Qompoter), Inqlude (the Qt libraries listing), and maybe others in future versions.
* Unstructured one like development forges (Github and al.).

Let's dig dipper into each type of repositories to see how to use them and eventually manage them.

Inqlude - Listing of Qt application
---------------------

[Inqlude](https://inqlude.org/) is a open project which aims to list all Qt libraries and modules to promote them and help Qt developpers. In addition to this listing, the project provides also two clients to browse and download libraries. For some of theses libraries, the client will install them globally into your system, and a simple `QT += module-name` will allow you to use them in your project.
The objectives of Inqlude are different from Qompoter, but there are some similarities.

Qompoter uses heavily the Inqlude listing of libraries and modules. By default, when running `qompoter install`, Qompoter search required packages of the project into the Inqlude repository. If available, it downloads them using information provided by Inqlude. This is very handy. This is also promising, a lot can be done to improve the interraction with Inqlude and ease the installation of these packages.

To check the availability of a package in Inqlude, use `qompoter inqlude --search <package-name>`. Please notice some information are deprecated in the Inqlude listing, some packages may not exist anymore. Please report any issues to the [Inqlude data project](https://github.com/cornelius/inqlude-data).

Example:

    $ qompoter inqlude --search attica
    Qompoter
    ======== inqlude

    * attica/attica 
    Attica 5.25.0
    VCS: https://projects.kde.org/projects/frameworks/attica/repository
    Download: http://download.kde.org/stable/frameworks/5.25/attica-5.25.0.tar.xz

    done

Under the hood, Qompoter caches the [inqlude-all.json file](http://inqlude.org/inqlude-all.json) listing all Qt packages known by Inqlude. You can check, this file is included at the end of the "[qompoter.sh file](https://github.com/Fylhan/qompoter/blob/master/qompoter.sh#L1298)". This way, Qompoter can know really quickly if a package is available in the Inqlude repository and retrieve how to download and install it locally to your project. However, this list has to be updated... At the moment, this is only done when a new version of Qompoter pops up. This can be done better. If you really need an up to date Inqlude listing, download the last [inqlude-all.json file](http://inqlude.org/inqlude-all.json) and use the following command line: `qompoter install --inqlude-file inqlude-all.json`. It may take some time to parse the Inqlude file.

Forges - Github and al.
---------------------

There are numerous of development forges around the Web, and some of them are really famous, especially since Github arrival. Good, it gives us access to a lot of C++ raw packages ready to be used.

In order to use a forge as the repository for all required packages of a project, use the command line: `qompoter install --repo https://github.com`.

If you prefer to use it only for one package (or some of them), add the following to the "qompoter.json" file of the project:

    "repositories": {
        "vendor-name/project-name": "https://framagit.org",
        "fylhan/posibrain": "https://github.com"
    }

Qompoter is able to recognize the download mechanism as Git for several forges based on the URL: github, git.kde, gitkde, gitorious, code.qt.io, git.freedesktop and framagit. There is actually no way to provide the repository type of other forges at the moment, this is a missing feature.

Qompotist-fs - Repository Structure
---------------------

Qompotist-fs is a small repository defined for Qompoter. It is just a file system structure which allows to store sources and binaries in a way letting Qompoter search and retrieve them. Qompotist-fs could store raw sources files and libraries or Git repositories.

An example is better than a lot of explaination: the repository below contains 3 different projects:

* Project A (directory "project_A"): raw source files are available; versions are available through different directories named with the version number.
* Project B (directory "project_B"): raw source files are available in addition to pre-compiled libraries for Linux 32/64 bits or Windows; versions are available through different directories named with the version number (library version is suffixed by "-lib").
* Project C (directory "project_C"): source files are available through a Git repository (using tag for versionning) in addition to pre-compiled libraries for Linux 32/64 bits or Windows; Git tags are used for versionning of source files; library versions are available through different directories named with the version number suffixed by "-lib".

```
qompoter-repository
    project_A
        v0.9.0
            files...
            qompoter.json
            qompoter.pri
        v1.0.0
            files...
            qompoter.json
            qompoter.pri
        v1.1.0-alpha
            files...
            qompoter.json
            qompoter.pri
    project_B
        v1.1.0
            files...
            qompoter.json
            qompoter.pri
        v1.1.0-lib
            include
                header files...
            lib_linux_32
                .a, .so, ...
            lib_linux_64
                .a, .so, ...
            lib_windows
                .a, .dll, ...
            qompoter.json
            qompoter.pri
    project_C
        v1.0.0-lib
            include
                header files...
            lib_linux_32
                .a, .so, ...
            lib_linux_64
                .a, .so, ...
            lib_windows
                .a, .dll, ...
            qompoter.json
            qompoter.pri
        project_C.git
```

A such repository can be used by Qompoter using the command line: `qompoter install --repo /<path>/qompoter-repository`.

There are some requirements about repositories:

* Repository files shall be available using the "ls" and "cp" commands.
* Repository CSV repositories shall be available using Git commands, especially `git clone` and `git pull`.
