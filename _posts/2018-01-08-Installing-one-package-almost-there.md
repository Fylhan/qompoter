---
layout: post
title: "Installing one package: almost there!"
date: 2018-01-09
---
During the end of 2017, I spent some time to provide the new "Install one package" feature using the command `qompoter install vendor/packagename [version]`. It is now almost ready! It allows to update only one package (with or without its dependencies thanks to `--no-dep`) instead of downloading all packages, which is pretty useful when you are working in a train with a slow Internet connexion over VPN ;-) I have also added a `--save` option to add a new package to the qompoter.json file using command line, but this part is not tested yet.
Anyway, it's available in the master branch, feel free to try and it! Feebacks would be appreciated.

The hard parts was to update existing vendor.pri and qompoter.lock files. Until ten I was only adding stuff at the end of these files, but for this feature, I had to replace existing lines (if any) to keep a correct order. I improved a lot in my understanding of [sed](http://links.la-bnbox.fr/?searchterm=sed)!

Once the work on `--save` option will be finished, I will be ready to start on the `qompoter install / update` feature which is one of my most wanted feature.
