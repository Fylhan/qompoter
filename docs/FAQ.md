Qompoter FAQ
========

Some questions/answers you may (or may not) ask yourself about Qompoter.

Table of Contents
---------------------

* [Can I use Qompoter in production?](#can-i-use-qompoter-in-production)
* [Which platforms does it run on?](#which-platforms-does-it-run-on)
* [Is Qompoter open source?](#is-qompoter-open-source)
* [I ran qompoter install but one of the Git based package has not been updated...](#i-ran-qompoter-install-but-one-of-the-git-based-package-has-not-been-updated)
* [What is this qompote.pri file?](#what-is-this-qompotepri-file)
* [Why "Qompoter"?](#why-qompoter)
* [Why building Qompoter and not using something already there?](#why-building-qompoter-and-not-using-something-already-there)
* [How did you choose the Qompoter CLI syntax?](#how-did-you-choose-the-qompoter-cli-syntax)

Can I use Qompoter in production?
---------------------

The Qompoter project has started at the end of 2014, reached version 0.2 in the end of 2016. and 0.3 in the middle of 2017. This is still a young project with some known bugs, however the main command line options and "qompoter.json" structure should not change a lot in the future and stay stable. I have a small amount of time to improve this tool, but I have it several time a week which allows me to fix things quite quickly, and to improve stuff step by step.

Today, Qompoter is used in production by a small team, it really ease the sharing and repeatability of the build between several people.
It is up to you! Please, share your experience.

Which platforms does it run on?
---------------------

Qompoter has been heavily tested under Linux. It works also well on Windows using [Git Bash](https://git-scm.com/).
It should also work on Mac, FreeBSD and more widely on Windows (Cygwin or Mysys command line) because it is Bash based, but I did not test it yet.

Is Qompoter open source?
---------------------

Oh yes, Qompoter is open source and also free as in freedom (and free beer)! It is distributed under the [LGPL3+](LICENSE) license: *you can freely use it in any projects, even closed ones. Just keep in mind that if you modify Qompoter, you shall provide these updates as open source. Thanks!* The project is hosted on GitHub.

Can I use SVN or Mercurial with Qompoter?
---------------------

Nope, sorry, only Git at the moment. A basic support of SVN might be added in the future.

I ran `qompoter install` but one of the Git based package has not been updated...
---------------------

If you project targets a commit number (e.g. #82bbdf9) or a tag which have been deleted and re-created (no, you should not do that: `git tag -d v1.0 && git push origin :refs/tags/v1.0`), Qompoter may fail (and sometimes fail silently!) to update a Git based package.

Until this is fixed, the tricks is to backup the "vendor" directory, delete it and run `qompoter install` again. Like this:

```bash
qompoter export
rm -rf vendor
qompoter install
```

If everything is ok, wait some times to be sure, you could delete the backup archive.

What is this qompote.pri file?
---------------------

The "qompote.pri" defines several new functions to be used in qmake ".pro" or ".pri" files, especially to help managing several architecture of compilation (x86, arm, ...). This file is included at the beginning of the "vendor.pri" file.

The new function can be used into any ".pro" or ".pri" file once `include($$PWD/vendor/qompote.pri)` or `include($$PWD/vendor/vendor.pri)` is added in it.

More about this in [Home-made Qompote](Home-made-qompote.md).

Why "Qompoter"?
---------------------

The word "Qompoter" is near the word "Composer" which is the name of _THE_ dependency manager for PHP. Its ease of use was inspiring for building Qompoter.

Also, in French, "Qompoter" is near the word "Compote" which means "Marmalade". Who does not love marmalade? More, you can do your own marmalade yourself with whatever fruits you like (do not forget the sugar)! Just like "Qompoter": make your own projects with whatever C++ packages you like.

That is why "Qompoter".

Why building Qompoter and not using something already there?
---------------------

This is a good question. Let's study what is already there, but please notice this is still a work in progress...
There are already some dependency managers for the C++ environment:

* [inqlude](http://inqlude.org/) Listing existing Qt libraries and modules
    * Client is written in Ruby.
    * Qt and qmake only.
    * Huge list of packages, but only a bunch of them can be easily imported using the existing clients.
    * Client is open source: GPL.
* [Conan](https://github.com/conan-io/conan) C/C++ distributed package manager
    * Written in Python.
    * Cmake, make, gcc and whatever but no qmake yet.
    * Dedicated repository, with possibility to host its own, with a lot of packages.
    * Packages can be easily imported, especially in CMake files. It supports sources and binaries with several architectures in a very advanced ways. More, packages are downloaded in a cached repository which allows offline usage, great!
    * Open source: MIT. Premium plan available.
    * This solution really need more investigation.
* [CPM](https://github.com/iauns/cpm) C++ package manager using CMake
    * Written in C++.
    * Cmake only.
    * Dedicated repository with lot of packages: [CPM rocks](http://www.cpm.rocks/).
    * Open source: MIT.
* [QPM](https://github.com/Cutehacks/qpm) Qt package manager
    * Written in Go.
    * Qmake only.
    * Dedicated repository with several packages:  [QPM repository](http://www.qpm.io/packages.html)
    * Open source: Artistic license.
* [QtPods](https://github.com/qt-pods/qt-pods) Unify packaging of fragment of Qt codes
    * Written in C++.
    * Qmake only.
    * Dedicated repository.
    * Open source: AGPL.

There is also [npm](https://github.com/npm/npm) (Node Package Manager) which is actualy more generic than just Node.js. Still it seems difficult to provide easy installation of a C++ dependency manager based on "npm". More, I am not sure the C++ community is willing to use something based on "npm".

When I decided to start building Qompoter, I asked myself: what do I really need?

* Being able to add easily pieces of codes and libraries to my projects. This can be raw source files, Git repositories or pre-compiled libraries.
* Describing the required dependencies of a project so that I can remove them from my Git and download them once and for all (or until the next update).
* Being able to work offline (yes, I code a lot in the train) but still working in team and sharing codes.
* I am only targeting Qt and qmake at the moment. However I really like the idea of being able to have the same experience independently of the C++ build system: qmake, cmake, make, whatever.
* It seems important to have something cross-platform (Linux, Windows, Mac) and easy / small to install. That is why I am not very found of something built on Ruby, Go or even Python. Bash, C or C++, maybe Qt, seems more appropriate, especially for a _C++_ dependency manager.

That is why I started building Qompoter. In Bash because it is easy to share and can still run in Linux, Mac and even Windows. It also involves less boilerplate than C++ to kick-off the project.

Today, Qompoter is used in production by a small team, it still have some issues but really ease the sharing and repeatability of the build between several people. Please, share your experience.

How did you choose the Qompoter CLI syntax?
---------------------

During the first days of Qompoter, I was using Composer, the PHP dependency manager, a lot. So yes, Qompoter is well inspired from Composer concepts, but I also tried to use the most common syntax.

| Project  | Install                 | Update   | Add in depencency list file |
|:--------:|:-----------------------:|:---------:|:--------------------------:|
| composer | `install` (using lock)  | `update` | `require`
| npm      | `install`               | `update` | `install --save`
| yarn     | `install` (using lock)  | `update` | `add`
| bower    | `install`               | `update` | `install --save`
| conan    | `install` (using lock?) | ?        |
| maven    | `install`               | N/A      | N/A
