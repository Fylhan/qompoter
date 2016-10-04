Qompoter Roadmap
================
Version 0.2
-----------
* [x] Recursive dependencies
* [x] Allow soft version management v1 (e.g. v0.3.*)
* [x] Search in the inqlude repository
* [x] Create auto-completion script
* [x] Add "--no-qompote" flag
* [ ] Clean documentation and release

Version 0.3
-----------
* [ ] Update automaticaly the inqlude repository data
* [ ] Integrate automaticly inqlude packages if possible (generate qompoter.pri, ... ?)
* [ ] Prevent from overriding changes (md5sum)
* [ ] Allow package to be available as zip or tar in repositories (this will also preserve symbolic links and reduce space)
* [ ] qompoter init
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

