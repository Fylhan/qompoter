Qompoter Roadmap
================

Version 0.2 - released 2016, october
-----------

* [x] Recursive dependencies
* [x] Allow soft version management v1 (e.g. v0.2.\*)
* [x] Search in the inqlude repository
* [x] Create auto-completion script
* [x] Add "--no-qompote" flag
* [x] Clean documentation and release

Version 0.3
-----------

* [x] Fix Git based package issue: branch, tag, commit ; first install or update
* [x] Fix: download lib does not failed properly
* [*] New action: qompoter init
* [*] New action: qompoter export --repo
* [*] New action: qompoter install / update (md5sum + qompoter.lock)
* [x] Feature: Prevent from overriding manual changes for Git packages in vendor (git status)
* [ ] Feature: Prevent from overriding manual changes for all packages in vendor (md5sum)
* [*] Feature: Install packages from tarball (this will also preserve symbolic links and reduce space)
* [*] Feature: Download packages using HTTP
* [*] Enhancement: qompoter export with compression / optimization
* [ ] Clean documentation and release

Version 0.4
-----------

* [ ] New action: qompoter release
* [ ] Feature: Cache downloaded packages
* [ ] Feature: Integrate automaticly inqlude packages if possible (generate qompoter.pri, ... ?)
* [ ] Feature: Update automaticaly the inqlude repository data
* [ ] Installation: create npm package
* [ ] Clean documentation and release

Future versions
-----------

* [ ] Installation: create Debian package
* [ ] Installation: create other Linux package
* [ ] Installation: qompoter self-update (from Github)
* [ ] Installation: install Qompoter though the "Qt Maintenance Tool"
* [ ] New action: qompoter require packagename
* [ ] Feature: Allow soft version management v2 (e.g. ^v1.0 etc)
* [ ] Feature: Search in other package manager repositories (QPM, CPM, ...)
* [ ] Feature: Increase security by checkin integrity of packages (md5sum)
* [ ] Feature: qompoter install --repo vendor.zip
* [ ] Feature: add qompoter install --local / --global
* [ ] Support extension using qompoter-command available in PATH
* [ ] Integrate automatically Qt plugins if possible (generate qompoter.pri, ... ?)
* [ ] Integrate into QtCreator
* [ ] Split qompoter.sh into several files and add build step to create qompoter.sh
* [ ] Describe and implement a "Packagist" like server for Qompoter
* [ ] Use QT += package instead of CONFIG which leverage the usage of include(vendor.pri)
* [ ] Support CMake
* [ ] Check Windows support
* [ ] JSON schema for qompoter.json
* [ ] Translate doc into french
* [ ] Better documentation
