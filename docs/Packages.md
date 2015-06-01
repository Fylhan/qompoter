Packages
========

Two kinds of packages
---------------------
* '''Library''': Qompoter download the library , install it locally or globally, and create an adapted vendor.pri -> you just need to use it
	* Yes but... the library compilation shall match your project: same compilator, same Qt version, same arch (32bit / 64 bit), same OS, ...
	* Still useful for company scenarii: someone build all required libraries and make them available in a private / online repositories
* '''Source files''' compiled with your projects: Qompoter download the source files and create an adapted vendor.pri -> use it and the packages will be compiled with your project

