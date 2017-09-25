Qompoter Roadmap
================

Version 0.4 - in progress
-----------

* [ ] Installation: Create Ubuntu/Snap package (?)
* [ ] New action: qompoter install <packagename>
* [ ] New action: qompoter install / update (using qompoter.lock)
* [x] Feature: Add aliases for most used actions e=export, i=install, u=update
* [ ] Feature: Prevent from overriding manual changes for all packages in vendor (md5sum)
* [ ] Feature: Improve qompoter inspect (show only modified packages...)
* [ ] Feature: Update automaticaly the inqlude repository data
* [ ] Feature: Support CMake
* [ ] Bugfix campaign
  * [ ] Fix: url field is not always filled in lock file
* [ ] Clean documentation and release

Version 0.3 - released 2017, august
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

Version 0.2 - released 2016, october
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

* [ ] New action: qompoter release
* [ ] Installation: create Debian package
* [ ] Installation: create other Linux package
* [ ] Installation: qompoter self-update (from Github)
* [ ] Installation: install Qompoter though the "Qt Maintenance Tool"
* [ ] Feature: Cache downloaded packages
* [ ] Feature: Integrate automaticly inqlude packages if possible (generate qompoter.pri, ... ?)
* [ ] Feature: Allow soft version management v2 (e.g. ^v1.0 etc)
* [ ] Feature: Search in other package manager repositories (QPM, CPM, ...)
* [ ] Feature: Increase security by checkin integrity of packages (md5sum or SHA1, SHA-256, ...)
* [ ] Feature: qompoter install --repo vendor.zip
* [ ] Feature: add qompoter install --local / --global
* [ ] Feature: Improve qompoter export with compression / optimization
* [ ] Support extension using qompoter-command available in PATH
* [ ] Integrate automatically Qt plugins if possible (generate qompoter.pri, ... ?)
* [ ] Integrate into QtCreator
* [ ] Split qompoter.sh into several files and add build step to create qompoter.sh
* [ ] Describe and implement a "Packagist" like server for Qompoter
* [ ] Use QT += package instead of CONFIG which leverage the usage of include(vendor.pri)
* [ ] Check Windows support
* [ ] Support SVN based packages
* [ ] JSON schema for qompoter.json
* [ ] Translate doc into french
* [ ] Take a look http://www.pkgsrc.org/
* [ ] Better documentation
