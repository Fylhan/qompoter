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

* [ ] qompoter init
* [ ] Fix Git based package issue: branch, tag, commit ; first install or update
* [ ] Do not automaticaly overide Git package in vendor with manual changes
* [ ] Allow package to be available as zip or tar in repositories (this will also preserve symbolic links and reduce space)
* [ ] Prevent from overriding manual changes for all packages in vendor (md5sum)
* [ ] Integrate automaticly inqlude packages if possible (generate qompoter.pri, ... ?)
* [ ] Update automaticaly the inqlude repository data
* [ ] qompoter install --repo vendor.zip
* [ ] qompoter update (md5sum + qompoter.lock)
* [ ] Clean documentation and release

Future versions
-----------

* [ ] Allow soft version management v2 (e.g. ^v1.0 etc)
* [ ] Search in other package manager repositories (QPM, CPM, ...)
* [ ] First security level: integrity of packages (md5sum)
* [ ] qompoter self-update (from Github)
* [ ] qompoter export --repo / --vendor
* [ ] qompoter require
* [ ] Better documentation
* [ ] Support extension using qompoter-command available in PATH
* [ ] FAQ
* [ ] Translate doc into french
* [ ] Integrate automatically Qt plugins if possible (generate qompoter.pri, ... ?)
* [ ] Integrate into QtCreator
* [ ] Split qompoter.sh into several files and add build step to create qompoter.sh
* [ ] Install Qompoter though the "Qt Maintenance Tool"
* [ ] Add Qompoter to Debian and other Linux repositories
* [ ] Describe and implement a "Packagist" like server for Qompoter
* [ ] Add qompoter install --local / --global
* [ ] Use QT += package instead of CONFIG which leverage the usage of include(vendor.pri)
* [ ] Support CMake
* [ ] Check Windows support
* [ ] JSON schema for qompoter.json
