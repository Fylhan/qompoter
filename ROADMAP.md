Qompoter Roadmap
================

Version 0.5 - in progress
-----------

* [ ] Study: Make a study around `qompoter install` / `qompoter update` / `qompoter install --save` (compare with Composer, npm, yarn) and post the result into the blog
* [ ] Installation: Create Debian package (?)
* [ ] Installation: Create Ubuntu/Snap package (?)
* [ ] Installation: Create FlatPack package (?)
* [ ] Feature: Support `--save --dev` option in `qompoter require <packagename>`
* [x] New action: `qompoter install` / `qompoter update` (using lock file)
  * url is ok, unit test are ok, cannot download on Github?
* [ ] Feature: Propose to download source version if lib one is outdated
* [ ] Feature: Allow soft version management v2 (e.g. >=v2.1.3)
* [ ] Feature: Prevent from overriding manual changes for all packages in vendor (md5sum)
* [ ] Feature: Update automatically the inqlude repository data
* [ ] Feature: Support `--no-dev` option in `qompoter export --repo`
* [ ] Feature: Support `--prefer-source` option in `qompoter update` to prefer source packages instead over library packages
* [ ] Feature: Support CMake
* [ ] Bugfix campaign
  * [ ] Fix: Url field is not always filled in lock file
  * [ ] Fix: Add dev packages to "require-dev" in lock file and remove them from "require"
  * [ ] Fix: When using local repository, libraries are still searched first in Inqlude repository
  * [ ] Fix: If a package is manually deleted, `qompoter inspect` displays an unexpected error `find: ‘vendor/package-dir’: No file or folder of this type`
* [ ] Clean documentation and release

Version 0.4 - released 2019, December
-----------

* [x] New action: `qompoter install <packagename>`
* [x] Feature: Add `--no-dep` flag to not load dependencies during `qompoter install` or `qompoter install <packagename>` (alias of `--depth 0`)
* [x] Feature: Add aliases for most used actions e=export, i=install, u=update
* [x] Feature: Improve `qompoter inspect` (show only modified packages by default, now use `--all` to list all of them)

Version 0.3 - released 2017, August
-----------

* [x] Installation: Create npm package
* [x] New action: qompoter init
* [x] New action: qompoter export --repo (export vendor as a re-usable Qompoter repository, nice!)
* [x] New action: qompoter inspect (list modified packages)
* [x] Feature: Let "qompoter install" generates md5sum + qompoter.lock
* [x] Feature: Prevent from overriding manual changes for Git packages in vendor (git status)
* [x] Feature: Install packages from tarball (this will also preserve symbolic links and reduce space)
* [x] Feature: Download packages using HTTP
* [x] Feature: More verbosity levels
* [x] Bugfix campaign
* [x] Clean documentation and release

Version 0.2 - released 2016, October
-----------

* [x] Recursive dependencies
* [x] Allow soft version management v1 (e.g. v0.2.\*)
* [x] Search in the inqlude repository
* [x] Create auto-completion script
* [x] Add "--no-qompote" flag
* [x] Clean documentation and release

Version 0.1
-----------

Proof of concept.

Plan for future
-----------

* [ ] New action: `qompoter release`
* [ ] Installation: Create other Linux package
* [ ] Installation: `qompoter self-update` (from Github)
* [ ] Installation: install Qompoter though the "Qt Maintenance Tool"
* [ ] Feature: Cache downloaded packages
* [ ] Feature: Integrate automatically inqlude packages if possible (generate qompoter.pri, ... ?)
* [ ] Feature: Allow soft version management v3 (e.g. ^v1.0 etc)
* [ ] Feature: Search in other package manager repositories (QPM, CPM, ...)
* [ ] Feature: Increase security by checking integrity of packages (md5sum or SHA1, SHA-256, ...)
* [ ] Feature: Support `--force=<number>` and `--bypass=<number>`
* [ ] Feature: `qompoter install --repo vendor.zip`
* [ ] Feature: add `qompoter install --local / --global`
* [ ] Feature: Improve qompoter export with compression / optimization
* [ ] Support extension using qompoter-command available in PATH
* [ ] Integrate automatically Qt plugins if possible (generate qompoter.pri, ... ?)
* [ ] Integrate into QtCreator
* [ ] Split `qompoter.sh` into several files and add build step to generate `qompoter.sh`
* [ ] Describe and implement a "Packagist" like server for Qompoter
* [ ] Use `QT += package` instead of CONFIG which leverage the usage of include(vendor.pri)
* [ ] Check Windows support
* [ ] Check Mac support
* [ ] Support SVN based packages
* [ ] JSON schema for qompoter.json
* [ ] Translate doc into French
* [ ] Better documentation
