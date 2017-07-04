Contribution Guide
========

Qompoter is distributed under the [LGPL3+](LICENSE) license.
*Therefore, you can freely use it in any projects, even closed ones. Just keep in mind that if you modify Qompoter, you shall provide these updates as open source. Thanks!*

Please feel free to contribute!

* If you would like to modify something, it is better to open first an issue just to be sure I am not working on it already, then feel free to send a Pull Request and I will consider adding your changes to the nominal branch.
* If you would like to participate but do not have any idea, take a look at the [roadmap](ROADMAP.md). Update or translation of the documentation are always welcome!
* Feel free to share
* If you have any ideas, critics, suggestions or whatever you want to call it, please open an issue. I will be happy to hear from you what you would like to see in this tool. I think about all suggestions, and I try to add those that make sense.

I hope the following sections will help you to implement new stuff on Qompoter.

Making changes to Qompoter
--------

Qompoter is at the moment composed of only one big file: "qompoter.sh". It is planned to split this file into smaller scripts and to build it as one script file using a Makefile.

### Table of content of "qompoter.sh"

* Declaration of global variables
* Copy/paste of the [JSON.sh](https://github.com/dominictarr/JSON.sh) library
* Usage function
* Templates for Qompoter .pri files
* Qompoter internal functions
* Qompoter external functions (i.e. actions)
* Parsing of the command line arguments
* Copy/paste of the [inqlude](https://inqlude.org/) repository

Running unit tests
--------

Qompoter is provided with a set of unit tests to validate the code and reduce regression risks. Unit tests are run regularily thanks to Travis CI.

You can run unit tests on your own by launching the script: `./run-all-tests.sh`

Some unit tests are using online Git repositories. To ignore these tests, you should launch: `./run-all-tests.sh --offline`

In the behind, "run-all-tests.sh" is simply running one by one the test scripts of the "test" directory. To run only one test case, you can launch: `cd test && ./<name-of-the-test-case>.sh`

Adding a completely new test case
--------

To add a new test case, create a new file in the "test" directoy: "<name-of-the-test-case>.sh". A successful test case exists with 0, a skipped one exists with 255, otherwize it fails and exists with the number of failed tests.

Updating an existing test case
--------

Most test cases are launching a Qompoter action (e.g. "install", "export", ...) on different "qompoter.json" files. The Qompoter output is then compared against a "qompoter.expected" files, and the content of the "vendor" directory is compared against the "qompoter.vendor.expected" files. Feel free to add a new element in a "qompoter.json" file and updating accordingly "qompoter.expected"  and "qompoter.vendor.expected" files; or to generate a new set of "qompoter.json", "qompoter.expected"  and "qompoter.vendor.expected" files.
