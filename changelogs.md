Qompoter Changelogs
===================

[0.6.0] - released 2023-05-09
-------

### Added

* Feature: Add hints to `install` and `update` actions to notify when a higher version is available
* Support `--no-hint` option in `install` and `update` actions to prevent display of hints
* Add elapsed time in logs in very very verbose mode (`-VVV`)

### Changed

* Renamed action: `qompoter require` to `qompoter add` and `qompoter updateOne` with the exact same behavior (`qompoter require` is deprecated)
* `add` and `updateOne` actions are now automatically saving in Qompoter and lock files. Use `--no-save` to avoid this behavior (`--save` is deprecated)
* Update embedded documentation
* Reorganise ordering of functions in qompoter.sh

[0.5.1] - released 2023-01-31
-------

### Fixed

* Stable tags are now sorted before their related alpha and RC tags (e.g. v1.1.10 is now chosen instead of v1.1.10-RC1)

[0.5.0] - released 2022-05-25
-------

### Breaking changes

* Renamed action: `qompoter install <packagename>` to `qompoter require <packagename>`
* Renamed action: `qompoter install` to `qompoter update`

### Fixed

* KDE projects loaded from Inqlude are now using GitLab
* Now compatible with Busybox based Linux system like Alpine

### Added

* Add support for the "gitolite" Git repository which does not use vendor name
* New action: `qompoter update`
* New action: `qompoter inspect --tree`

[0.4.1] - released 2019-12-20
-----------

### Added

* Add "gitolite" as well-known Git repository

[0.4.0] - released 2018-01-24
-------

### Breaking changes

* Change default repository path to Github and read `QOMP_REPO_PATH` environment variable to select another one

### Fixed

* Fix: Do not erase an existing 'vendor.pri' file when a `qompoter install` fail
* Fix: Git remote update was failing when running `qompoter export --repo` on an existing repository
* Fix: Do not load sub-dependencies for library packages
* Fix: Several corrections, maybe not complete, in `downloadLibPackage`

### Added

* New action: `qompoter install <packagename>`
  * Take care of updating existing lock file in `qompoter install <packagename>`
  * Take care or using the same order during lock file update in `qompoter install <packagename>`
  * Take care of updating existing vendor.pri in `qompoter install <packagename>`
  * Take care or using the same order during vendor.pri update in `qompoter install <packagename>`
  * Take care of updating existing date in lock file after `qompoter install <packagename>`
  * Auto-detect package version using Qompoter file if missing in `qompoter install <packagename>`
  * Support `--save` option in `qompoter install <packagename>`
  * Add doc about `qompoter install <packagename>`
* Feature: Add `--no-dep` flag to not load dependencies during `qompoter install` or `qompoter install <packagename>` (alias of `--depth 1`)
* Feature: Add specific library loader for GitLab forges

### Changed

* Feature: Improve `qompoter inspect` (show only modified packages by default, now use `--all` to list all of them)

[0.3] - released 2017, August
-----

* Installation: create npm package
* Fix: Git based package if changing from a branch to a tag or commit, now we first install otherwize update
* Fix: Error during lib downloading was not failing properly
* Fix: v1.1.3 was higher than v1.1.10
* Fix: Remove usage of "sed -z" not supported in older version of sed, and "sed -i" not supported by Solaris
* New action: qompoter init
* New action: qompoter export --repo (export vendor as a re-usable Qompoter repository, nice!)
* New action: qompoter inspect (list modified packages)
* Feature: Let qompoter install generates md5sum + qompoter.lock
* Feature: Prevent from overriding manual changes for Git packages in vendor (git status)
* Feature: Install packages from tarball (this will also preserve symbolic links and reduce space)
* Feature: Download packages using HTTP
* Feature: More verbosity levels
* Clean documentation

[0.2] - released 2016, October
-----

* Update qompote.pri with new qmake functions
* vendor.pri now also contains qompote.pri to avoid double inclusion
* Manage recursive dependencies
* Allow version number with star (e.g. `v0.3.*`), flag "--stable-only" allows to select only stable releases (e.g. v0.3.2 instead of v0.3.3-RC1)
* Search in the inqlude repository and download Git packages
* Create auto-completion script, oh yeah!
* /!\ Breaking changes: The concept of "action" have been introduced into the command line, you should now use `qompoter install` instead of just `qompoter`
* Add "inqlude" action
  * "--search" flag: search a package into the inqlude repository
  * "--minify" flag: minify the inqlide repository listing (JSON like inqlude-all.json) file provided with "--inqlude-file" flag
* Add "install" action to load qompoter.json and download listed packages
* Add "export" action to export the actual vendor dir as a zip archive
* Add "jsonh" action to parse JSON files (debuging purpose)
* Add "require" action to list packages required by the provided qompoter.json file
* Add "--file <file>" parameter to specify another file as qompoter.json
* Add "--inqlude-file <file>" parameter to specify another file as inqlude-all.json to search into the inqlude repository
* Add "--no-qompote" flag which prevent the creation of any Qompoter stuff like vendor.pri and qompote.pri
* Add "--no-color" flag which prevent fancy colors to be displayed
* Add unit tests, yeah!

[0.1]
-----

* First release
* List packages in qompoter.json and download them
* Generate qompote.pri and vendor.pri
