Command Line
============

Usage: qompoter [action] [ --repo <repo> | other options ]

Actions
------------

Select an action in: export, init, inspect, install, require

Other actions are useful for digging into Qompoter: inqlude, jsonh, md5sum.

### export

Exports the "vendor" directory as a dated archive. Depending of the options the archive will contain:

* A "copy and paste" vendor directory. The archive can be provided with the source code of an application and is easy to install: unzip the archive in the "vendor" directory.
* A re-usable Qompoter repository (type: qompotist-fs) thanks to the `--repo` option. The `qompoter install --repo <Qompoter repo>` can be used on this new Qompoter repository, which is really useful to share the dependencies of several applications in a team without any centralized online repository.

Examples:

```bash
# Export the "vendor" directory
qompoter export
# Export the directory called "myvendor"
qompoter export --vendor-dir myvendor
# Export vendor directory as a qompotist-fs repository
qompoter export --repo ~/other-qompoter-repo
```

The other features are not implemented yet.

### init

Generates Qompoter and Qt boilerplate for a new application. By providing a vendor name and a package name, the "init" action will generates:

* src and test directories
* qompoter.json and qompoter.pri
* README.md and changelogs.md
* .qmake.conf
* .gitlab-ci.yml

Notice: this action is too "Qtish" and too specific. It may change a lot in the future or even be deprecated.

Examples:

```bash
# Generate boilerplate for the "old/yoda" package starting from version 900.0
qompoter init old/yoda v900.0
```

The other features are not implemented yet.

### inspect

Inspect the packages available in the "vendor" directory and compare them with the information available in the "qompoter.lock" file in order to check changes since the packages has been retrieved.

This action is useful to show manual changes performed onto packages, and therefore to push them manually to the Qompoter repository. To override changes, use `qompoter install --force`, to keep them and continue the installation process normally use `qompoter install --by-pass`.

Examples:

```bash
# Inspect the "vendor" directory
qompoter inspect
# Inspect the "vendor" directory and lisy all packages, not only modified ones
qompoter inspect --all
# Inspect the directory called "myvendor" based on file "myqompoter.lock"
qompoter inspect --vendor-dir "myvendor" --file "myqompoter.json"
```

### install

Download and install locally (i.e. into a "vendor" directory) the packages listed as required into the "qompoter.json" file. Several options can be used to select another "qompoter.json" file, "vendor" directory, repository path or to select only nominal or stable packages.

The installation process generates a "qompoter.lock" file listing the downloaded packages, their selected version and a MD5 sum of each package.

Examples:

```bash
# Install all required packages
qompoter install --repo /Project
# Install only nominal required packages
qompoter install --no-dev --repo /Project
# Install only stable required packages
qompoter install --stable-only --repo /Project
# Install all required packages with specific options, and do not generate Qt specific stuff thanks to the "--no-qompote" option
qompoter install --repo /Project --file myqompoter.json --vendor myvendor --no-qompote --no-color
```

### require

With the `--list` options, lists the required packages of a project.

Example:

```bash
# List required dependencies of the project
qompoter require --list
# List required dependencies of "myqompoter.json" file
qompoter require --list --file myqompoter.json
```

The other features are not implemented yet.

### inqlude

With the `--search` option, allows to search packages into the [inqlude repository](https://inqlude.org/).

With the `--minify` option, allows to minify a "inqlude-all.json" file into something easily usable by Qompoter. This can be used to update the inqlude cached repository of Qompoter.

Examples:

```bash
# Search the "vogel/injeqt" package
qompoter inqlude --search vogel/injeqt
# Search the "vogel/injeqt" package but using another inqlude repository than the Qompoter cached one
qompoter inqlude --search vogel/injeqt --inqlude-file /home/me/Downloads/inqlude-all.json
# Minify the provided "inqlude-all.json" file
qompoter inqlude --minify --inqlude-file /home/me/Downloads/inqlude-all.json
```

The other features are not implemented yet.

### jsonh

Dig into a JSON file using the [SON.sh](https://github.com/dominictarr/JSON.sh) tool used by Qompoter.

Example:

```bash
qompoter jsonh --file myqompoter.json | grep "require"
```

### md5sum

Compute a MD5 sum of the given directory. It is used internally by Qompoter to compute the MD5 sum of each Qompoter package.

Example:

```bash
qompoter md5sum --vendor-dir vendor/luke
```

Options
------------

* **--all** List or apply actions to all elements depending of the action
  * Supported action is: (inspect)[#inspect]
* **--by-pass** By-pass error and continue the process
  * Supported actions are: export --repo, install
* **-d, --depth SIZE** Depth of the recursivity in the searching of sub-packages [default = 10]
* **--inqlude-file FILE** Pick the provided file to search into the inqlude repository
* **--file FILE** Pick another Qompoter file [default = qompoter.json]
* **-f, --force** By-pass error by forcing the action to be taken and continue the process
  * Supported actions are: export --repo, install
* **-l, --list** List elements depending of the action
  * Supported action is: require
* **--minify** Minify the provided file
  * Supported action is: inqlude
* **--no-color** Do not enable color on output [default = false]
* **--no-dev** Do not retrieve dev dependencies listed in "require-dev" [default = false]
  * Supported action is: install
* **--no-qompote** Do not generate any Qompoter specific stuffs like qompote.pri and vendor.pri [default = false]
  * Supported actions are: init, install
* **-r, --repo DIR** Select a repository path as a location for dependency research or export. It is used in addition of the "repositories" provided in "qompoter.json".
  * Supported actions are: export, install
* **--search PACKAGE** Search related packages in a repository
  * Supported action is: inqlude
* **--stable-only** Do not select unstable versions [default = false]
  * E.g. If `v1.*` is given to Qompoter, it will select "v1.0.3" and not "v1.0.4-RC1"
  * E.g. If `v1.*`" is given to Qompoter, it will select "v1.0.3" and not "v1.0.4-RC1"
  * Supported action is: install
* **--vendor-dir DIR** Pick another vendor directory [default = vendor]
  * Supported actions are: export, inspect, install, md5sum
* **-V, --verbose** Enable more verbosity
* **-VV** Enable really more verbosity
* **-VVV** Enable really really more verbosity
* **-h, --help** Display this help
* **-v, --version** Display the version
