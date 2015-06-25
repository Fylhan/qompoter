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

* **-r, --repo**                        Select a repository path as a location for package discovery. It is used in addition of the "repositories" field in qompoter.json. E.g. gits=https://github.com.
* **-f, --file <filename>**             Pick another filename as "qompoter.json"
* **-d, --working-dir <directory>**     Pick another working directory as the current one.
* **--vendir-dir <directory>**          Pick another vendor directory as "vendor".
* **--no-dev**                          Skip packages for development listed in require-dev
* **-g, --global**                      Install the packages globaly on the machine instead of localy
* **-V, --verbose**                     Increase verbosity of messages
* **-v, --version**                     Display this Qompoter version
* **-h, --help**                        Display help
