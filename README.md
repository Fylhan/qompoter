Qompoter
================================

An attempt of dependency manager for Qt / C++, because I am sick of managing each C++ piece of code separately!


[![Build Status](https://travis-ci.org/Fylhan/qompoter.svg?branch=master)](https://travis-ci.org/Fylhan/qompoter)

The current version is still a work in progress but it is now usable for non-critical projects. Still, you can:

* describe the required dependencies of your project in a "qompoter.json" file
* search and download all these dependencies (also recursively for sub-dependencies) in a "vendor" directory, from the [inqlude](https://inqlude.org/) repository, a development forge (like Github) or a [local Qompotist-fs repository](docs/Repositories.md)
* generate "qompote.pri" and "vendor.pri" files to be included and used in ".pro" files for Qt

Installation
-------------

Download Qompoter and move it to a place accessible in the `PATH`:

    wget https://raw.githubusercontent.com/Fylhan/qompoter/a406500/qompoter.sh -O qompoter.sh
    sudo mv qompoter.sh /usr/bin/qompoter
    qompoter --version
     Qompoter v0.2.6
     Dependency manager for C++/Qt by Fylhan

To enable autocompletion, download the script and source it in your `~/.bashrc` file:

    wget https://raw.githubusercontent.com/Fylhan/qompoter/a406500/resources/qompoter_bash_completion.sh -O qompoter_bash_completion.sh
    sudo mv qompoter_bash_completion.sh /usr/share/bash-completion/completions/qompoter
    echo "test [ -f /usr/share/bash-completion/completions/qompoter ]; source /usr/share/bash-completion/completions/qompoter" >> ~/.bashrc

Qompoter requires Bash, Git, sed and zip.

It works on Linux and Windows (using [Git bash](https://git-scm.com/)).
It should also work on Mac, FreeBSD and more widely on Windows (Cygwin or Mysys command line) because it is Bash based, but I did not test it yet.

Usage
-------------

In your project, create a qompoter.json file:

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
            "young/leia": "v0.5.*",
            "old/yoda": "dev-master"
        },
        "require-dev": {
            "milenium-falcon/han": "v1.0"
        },
        "repositories": {
            "old/yoda" : "https://github.com"
        }
    }

Then, download and install dependencies listed in your `qompoter.json` using:

    qompoter install

*For more information about the command line options, use `qompoter --help` or check the [online help](docs/Command-line.md).*

That's it! You can now include `vendor.pri` in the `.pro` file of your project, and use the dependencies that you required:

    CONFIG += luke leia yoda han
    include(vendor/vendor.pri)

Documentation
-------------

* [Concept of packages](docs/Packages.md)
* [Concept of repositories](docs/Repositories.md)
* [How to create a Qompoter.json file?](docs/Qompoter-json-file.md)
* [How to create a Qompoter.pri file?](docs/Qompoter-pri-file.md)
* [What is this qompote.pri file?](docs/Home-made-qompote.md)
* [Command line interface](docs/Command-line.md)
* [FAQ](docs/FAQ.md)

Releases
-------------

Qompoter is released under 2 versions:

* The current version is a proof-of-concept developed in bash, useful to kickoff the project without involving big development. It is actually working quite well and is now more than just a proof-of-concept.
* A more complete implementation has been started in C++/Qt and should provide more portability and robustness if the project grows. The development of this version is currently paused because Bash is actually suffisant at the moment.

In order to simplify numerotation, v0.1 to v0.6 are reserved for "qompoter.sh". Therefore, the first "qompoter" (C++/Qt) version is v0.7. This may change in the future.

There is a previsional [roadmap](TODO.md).

License
-------------

* Qompoter is distributed under the [LGPL3+](LICENSE) license. *Therefore, you can freely use it in any projects, even closed ones. Just keep in mind that if you modify Qompoter, you shall provide these updates as open source. Thanks!*
* Qompoter is using [JSON.sh](https://github.com/dominictarr/JSON.sh) under the MIT and Apache 2 license. Qompoter unit tests are also based on the JSON.sh architecture.

Please feel free to contribute.

If you have any ideas, critiques, suggestions or whatever you want to call it, please open an issue. I'll be happy to hear from you what you'd see in this tool. I think about all suggestions, and I try to add those that make sense.
