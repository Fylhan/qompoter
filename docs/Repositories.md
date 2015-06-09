Repositories
============

Select Repositories
---------------------

Update the Qompoter.ini file in you $HOME folder: ~/.config/qompoter/Qompoter.ini

	[Query]
	gits-repo=Path to repository A|Path to repostory B|...
	fs-repo=Path to repository A|Path to repostory B|...
	no-github=0
	
Repository Structure
---------------------

A package is identified by its vendor name, its project name, and by a version number. E.g. fylhan/qompoter/v1.0.0.
A package can be installed as a library (if a compiled version is available), or as source files.

The example below shows the folder structure of a repository containing 3 different projects:

* Project A: raw source files are provided, versions are available through different folders
* Project B : raw source files are available, and also a pre-compiled library for Linux 32/64 bits or Windows
* Project C : source files are available through a Git repository (using tag for versionning), and also a pre-compiled library for Linux 32/64 bits or Windows

	vendor_1
		project_A
			v0.9.0
				files...
				qompoter.json
				qompoter.pri
			v1.0.0
				files...
				qompoter.json
				qompoter.pri
			v1.0.0-featureX
				files...
				qompoter.json
				qompoter.pri
		project_B
			v1.1.0
				files...
				qompoter.json
				qompoter.pri
			v1.1.0-lib
				include
					header files...
				lib_linux_32
					.a, .so, ...
				lib_linux_64
					.a, .so, ...
				lib_windows
					.a, .dll, ...
				qompoter.json
				qompoter.pri
	vendor_2
		project_C
			v1.0.0-lib
				include
					header files...
				lib_linux_32
					.a, .so, ...
				lib_linux_64
					.a, .so, ...
				lib_windows
					.a, .dll, ...
				qompoter.json
				qompoter.pri
			project_C.git
				qompoter.json (optional)
