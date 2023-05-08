Qompoter
================================

An attempt of dependency manager for Qt / C++, because I am sick of managing each C++ piece of code separately!

[![Build Status](https://travis-ci.org/Fylhan/qompoter.svg?branch=master)](https://travis-ci.org/Fylhan/qompoter)

The current version is still a work in progress but is fully usable for simple and complex projects!

Check the [FAQ](docs/FAQ.md) to understand "Why Qompoter?", but here is what **Qompoter is good for**:

* easily share the required source dependencies of your Qt / C++ project with a team
  * describe them in a "qompoter.json" file
  * let Qompoter search and download them for you into a "vendor" directory
* share C++ code to the [inqlude](https://inqlude.org/) repository, a development forge (like Github) or any [local or remote Qompotist-fs repository](docs/Repositories.md)
* ease the repetability of the build thanks to the lock file
* work with several platforms (Linux, Windows, Mac, ...)
* keep it simple

Qompoter is also useful to share *library* (or binary) dependencies of you Qt / C++ project. However, keep in mind this is not that simple, this requires precompiling these dependencies somewhere for all your required targets (x86, x86_64, ARM, ...).

Installation
-------------

### Requirements

Qompoter requires Bash, Git, sed. Other tools like rsync, curl (or wget) and tar (or zip) may be useful for some advanced cases.

It works on Linux, including Busibox Linux based system like Alpine, and Windows (using [Git bash](https://git-scm.com/)).

It also works on MacOS, but requires additional packages to be installed with Homebrew (https://brew.sh/): `brew install gnu-sed && brew install coreutils`, then make sure to add these to your path, in order to use GNU sed and GNU date instead of the MacOS version:

```
PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
PATH=/usr/local/opt/gnu-sed/libexec/gnubin:$PATH
```

It should also work on FreeBSD and more widely on Windows (Cygwin or Mysys command line) because it is Bash based, but I did not test it yet.

### Using [npm](https://www.npmjs.com/)

```bash
$ npm install -g qompoter
$ qompoter --version
Qompoter v0.5.1
Dependency manager for C++/Qt by Fylhan
```

### From scratch

Download it from Github and move it to a place accessible in the `PATH`:

```bash
$ wget https://github.com/Fylhan/qompoter/releases/download/v0.5.1/qompoter.sh -O qompoter.sh && sudo mv qompoter.sh /usr/bin/qompoter
$ qompoter --version
Qompoter v0.5.1
Dependency manager for C++/Qt by Fylhan
```

The MD5 sum of qompoter.sh v0.5.1 version is `0374e612a2cb61fcb41673d7ed2abd34`.

The SHA512 sum of qompoter.sh v0.5.1 version is `c8b7fa2c9d20bf288c8c434ddebdee64698ed0eae7fa39ae5255f5c38613dae2b0124b20adac0e8e4c10419df69db36fb5c8e71d62032cae5bc86ff4e8eef7b6`.

To enable autocompletion, download the script and source it in your `~/.bashrc` file:

```bash
wget https://github.com/Fylhan/qompoter/releases/download/v0.5.1/qompoter_bash_completion.sh -O qompoter_bash_completion.sh && sudo mv qompoter_bash_completion.sh /usr/share/bash-completion/completions/qompoter
echo "test [ -f /usr/share/bash-completion/completions/qompoter ]; source /usr/share/bash-completion/completions/qompoter" >> ~/.bashrc
```

### Using Debian package (beta)

A Debian package can be generated using the script available in `resources/create-deb-package.sh`. Please share feedback!

Getting Started
-------------

In your project, create a qompoter.json file:

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
```

Then, download and install dependencies listed in your `qompoter.json` using:

```bash
qompoter update
```

*For more information about the command line options, use `qompoter --help` or check the [online help](docs/Command-line.md).*

That's it! Qompoter has downloaded all required dependencies into the `vendor` directory and you can now include `vendor.pri` in the `.pro` file of your project, and use the dependencies that you required:

```qmake
CONFIG += luke leia yoda han
include(vendor/vendor.pri)
```

Let's start coding!

During development, if you want to change / upgrade the version of an existing package, add or remove packages: update the `qompoter.json` file accordingly and run again `qompoter update`.

If you reached a milestone of your project and wanted to provide a backup of your project's dependencies, run `qompoter export` to create an archive file of the `vendor` directory, or `qompoter export --repo <path to a directory>` to create a Qompotist-fs repository on which you can run `qompoter update`. You may want to use `qompoter inspect` before to check you did not modified manually any packages in the `vendor` directory.

Important change between Qompoter 0.4 and 0.5
-------------

The `qompoter update` has been introduced and is identical to the <0.4 `qompoter install` action: take the `qompoter.json`, download dependencies and generate a `qompoter.lock` file listing the downloaded versions.

The `qompoter install` action has been modified as follow: take the `qompoter.lock` and download dependencies. This allows to download the same version used by the last `qompoter update` without computing again the potential variadic version numbers. 

Documentation
-------------

[Documentation is available online](https://fylhan.github.io/qompoter/) and in the `gh-pages` branch inside the `docs` directory.

* [Concept of packages](https://github.com/Fylhan/qompoter/blob/gh-pages/docs/Packages.md)
* [Concept of repositories](https://github.com/Fylhan/qompoter/blob/gh-pages/docs/Repositories.md)
* [Concept of package's versions](https://github.com/Fylhan/qompoter/blob/gh-pages/docs/Qompoter-json-file.md#require)
* [How to create a Qompoter.json file?](https://github.com/Fylhan/qompoter/blob/gh-pages/docs/Qompoter-json-file.md)
* [How to create a Qompoter.pri file?](dhttps://github.com/Fylhan/qompoter/blob/gh-pages/ocs/Qompoter-pri-file.md)
* [What is this qompote.pri file?](https://github.com/Fylhan/qompoter/blob/gh-pages/docs/Home-made-qompote.md)
* [Command line interface](https://github.com/Fylhan/qompoter/blob/gh-pages/docs/Command-line.md)
* [Contribution guide](CONTRIBUTING.md)
* [LICENSE](LICENSE)
* [FAQ](https://github.com/Fylhan/qompoter/blob/gh-pages/docs/FAQ.md)

There is a previsional [roadmap](https://github.com/Fylhan/qompoter/blob/gh-pages/docs/ROADMAP.md).

License
-------------

* Qompoter is distributed under the [LGPL3+](LICENSE) license. *Therefore, you can freely use it in any projects, even closed ones. Just keep in mind that if you modify Qompoter, you shall provide these updates as open source. Thanks!*
* Qompoter is using [JSON.sh](https://github.com/dominictarr/JSON.sh) under the MIT and Apache 2 license. Qompoter unit tests are also based on the JSON.sh architecture.

Please feel free to contribute.

If you have any ideas, critics, suggestions or whatever you want to call it, please open an issue. I will be happy to hear from you what you would like to see in this tool. I think about all suggestions, and I try to add those that make sense.
