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
* .gitignore

Notice: this action may be too "Qtish" and too specific. It may change in the future.

Examples:

```bash
# Generate boilerplate for the "old/yoda" package starting from version 900.0
qompoter init "old/yoda" v900.0
```

### inspect

Inspect the packages available in the "vendor" directory and compare them with the information available in the "qompoter.lock" file in order to check changes since the packages has been retrieved.

This action is useful to show manual changes performed onto packages, and therefore to push them manually to the Qompoter repository. To override changes, use `qompoter install --force`, to keep them and continue the installation process normally use `qompoter install --by-pass`.

Examples:

```bash
# Inspect the "vendor" directory
qompoter inspect
# Inspect the "vendor" directory and list all packages, not only modified ones
qompoter inspect --all
# Inspect the "vendor" directory and list all packages and display them as a tree, not only modified ones (wip)
qompoter inspect --tree
# Inspect the directory called "myvendor" based on file "myqompoter.lock"
qompoter inspect --vendor-dir "myvendor" --file "myqompoter.json"
```

To list packages required in the "qompoter.json" file, use [`qompoter require`](#require).

### install

Download and install locally into the "vendor" directory, the packages listed as required into the "qompoter.lock" file. Several options can be used to select another "qompoter.lock" file, "vendor" directory, repository path or to select only nominal or stable packages.

The `update` action does the same, using the "qompoter.json" file and generating a "qompoter.lock" file with the selected dependency versions ("v3.0.\*" -> "v3.0.2"). Even if a newer version of a package is pushed (like "v3.0."), the `install` action will use the "qompoter.lock" file and will allow to use the versions selected when `update` was used.

In case there is no "qompoter.lock" file, `install` will behave as `update` and generate a lock file for next time.

Examples:

```bash
# Install all required packages
qompoter install --repo /Project
# Install only nominal required packages
qompoter install --no-dev --repo /Project
# Install only stable required packages
qompoter install --stable-only --repo /Project
# Install all required packagesn listed in "myqompoter.lock" file, in a "myvendor" directory, without using color in stdout, and do not generate Qt specific stuff thanks to the "--no-qompote" option
qompoter install --repo /Project --file myqompoter.lock --vendor myvendor --no-qompote --no-color
```

### install (one package)

Download and install locally into the "vendor" directory, the requested package. If the version number is not provided, the one from the Qompoter file is used (if any). By default, the requested package and all its dependencies are installed. To only install or update the requested package alone, use `--no-dep` option. Several other options can be used to select another "qompoter.json" file, "vendor" directory, repository path or to select only nominal or stable packages.

The existing "qompoter.lock" file is updated, or a new one is created, listing the downloaded packages, their selected version and a MD5 sum of each package.

Examples:

```bash
# Install only the "http-parser-wrapper" package (from Github) with all its dependencies:
qompoter install qompoter/http-parser-wrapper dev-master --repo https://github.com
# Install only the "qhttp-wrapper" package (from Github) but do not install its dependencies:
qompoter install qompoter/qhttp-wrapper 3.1.* --no-dep --repo https://github.com
# Install only a stable version (listed in the "qompoter.json" file) of the "qhttp-wrapper" package (from Github), in a "myvendor" directory, with all its dependencies:
qompoter install qompoter/qhttp-wrapper --stable-only --repo https://github.com --file myqompoter.json --vendor myvendor
```

### require

List the required packages of a project from the "qompoter.json" file.

Example:

```bash
# List required dependencies of the project
qompoter require
# List required dependencies of "myqompoter.json" file
qompoter require --file myqompoter.json
```

The other features are not implemented yet.

To list packages available in the "vendor" directory, use [`qompoter inspect --all`](#inspect).

### update

Download and install locally into the "vendor" directory, the packages listed as required into the "qompoter.json" file. Several options can be used to select another "qompoter.json" file, "vendor" directory, repository path or to select only nominal or stable packages.

The installation process generates a "qompoter.lock" file listing the downloaded packages, their selected version and a MD5 sum of each package.

Examples:

```bash
# Install all required packages
qompoter update --repo /Project
# Install only nominal required packages
qompoter update --no-dev --repo /Project
# Install only stable required packages
qompoter update --stable-only --repo /Project
# Install all required packagesn listed in "myqompoter.json" file, in a "myvendor" directory, without using color in stdout, and do not generate Qt specific stuff thanks to the "--no-qompote" option
qompoter update --repo /Project --file myqompoter.json --vendor myvendor --no-qompote --no-color
```

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
  * Supported actions are: export --repo, install, update
* **-d, --depth SIZE** Depth of the recursivity in the searching of sub-packages [default = 10]
* **--inqlude-file FILE** Pick the provided file to search into the inqlude repository
* **--file FILE** Pick another Qompoter file [default = qompoter.json]
* **-f, --force** By-pass error by forcing the action to be taken and continue the process
  * Supported actions are: export --repo, install, update
* **-l, --list** List elements depending of the action
  * Supported action is: require
* **--minify** Minify the provided file
  * Supported action is: inqlude
* **--no-color** Do not enable color on output [default = false]
* **--no-dev** Do not retrieve dev dependencies listed in "require-dev" [default = false]
  * Supported action is: install, update
* **--no-dep** Do not retrieve dependencies, only use listed packages from the Qompoter file, or the one requested in command line [default = false]
  * Supported action is: install, update
* **--no-hint** Do not display hints on output (like higher versions) [default = false]
  * Supported action is: install, update
* **--no-qompote** Do not generate any Qompoter specific stuffs like qompote.pri and vendor.pri [default = false]
  * Supported actions are: init, install, update
* **-r, --repo DIR** Select a repository path as a location for dependency research or export. It is used in addition of the "repositories" provided in "qompoter.json".
  * Supported actions are: export, install, update
* **--search PACKAGE** Search related packages in a repository
  * Supported action is: inqlude
* **--stable-only** Do not select unstable versions [default = false]
  * E.g. If `v1.*` is given to Qompoter, it will select "v1.0.3" and not "v1.0.4-RC1"
  * E.g. If `v1.*`" is given to Qompoter, it will select "v1.0.3" and not "v1.0.4-RC1"
  * Supported action is: install, update
* **--tree** List all packages as a tree
* **--vendor-dir DIR** Pick another vendor directory [default = vendor]
  * Supported actions are: export, inspect, install, md5sum, update
* **-V, --verbose** Enable more verbosity
* **-VV** Enable really more verbosity
* **-VVV** Enable really really more verbosity
* **-h, --help** Display this help
* **-v, --version** Display the version
