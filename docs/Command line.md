Command Line
============

Installation
---------------------------------

Make the qompoter.sh script file runnable, and move it to a place accessible in the PATH:

    chmod u+x qompoter.sh
    mv qompoter.sh /usr/bin/qompoter

Usage
---------------------------------

At the root directory of your project, where qompoter.json is available, simply use `qompoter` to install all required dependencies in a "vendor" folder.

Some options are availables:

* **-r, --repo**	Select a repository path as a location for dependency research. It is used in addition of the "repositories" field in qompoter.json. E.g. *repo/repositories/vendor name/project name*
* **-v, --vendir-dir**	Pick another vendor directory as "vendor"
* **--no-dev**		Don't retrieve dependencies for development listed in "require-dev"
* **-h, --help**	Display help
* **    --version**	Display this Qompoter version
