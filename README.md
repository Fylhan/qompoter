Qompoter
================================

An attempt of dependency manager for Qt / C++. Because I am sick of managing each C++ piece of code separately!

Inspired by the well-known Composer PHP dependency manager.

The current version is still a work in progress. But still, you can:

* describe in a qomposer.config file your dependencies
* retrieve all these packages from file system
* generate a vendor.pri file to include and use in your .pro file

A lot have to be done to make it really usable.

Usage
--------------------------------

Make the script file runnable:

    sudo chmod u+x qompoter.sh

and install and deploy your required dependencies easily with Qompoter:

    ./qompoter.sh

That's it! You can now include vendor.pri in the .pro file of your project, and include the dependencies that you required:

    CONFIG += solilogger chartxy
    include(vendor/vendor.pri)

License
--------------------------------

Distributed under the LGPL3+ license.

If you have any ideas, critiques, suggestions or whatever you want to call it, please open an issue. I'll be happy to hear from you what you'd see in this lib. I think about all suggestions, and I try to add those that make sense.
