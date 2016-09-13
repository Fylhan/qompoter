Qompoter Changelogs
===================
Version 0.2
-----------
* Update qompote.pri with new qmake functions
* vendor.pri now also contains qompote.pri to avoid double inclusion
* Manage recursive dependencies
* Allow version number with star (e.g. v0.3.*), flag "--stable-only" allows to select only stable releases (e.g. v0.3.2 instead of v0.3.3-RC1)
* Search in the inqlude repository and download Git packages
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
* Add unit tests, yeah!

Version 0.1
-----------
* First release
* List packages in qompoter.json and download them
* Generate qompote.pri and vendor.pri