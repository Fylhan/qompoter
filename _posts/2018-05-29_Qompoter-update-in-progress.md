---
layout: post
title: "Qompoter update: in progress"
date: 2018-05-29
---
The implementation of the new action `qompoter update` is in progress! I pushed the first related commit today.
This new feature will ensure to always use the same dependency versions when using `qompoter install`. Indeed, in a near future, `qompoter install` will retrieve dependencies from the Qompoter lock file, and `qompoter update` will use the Qompoter file (`.json`) and generate the corresponding Lock file.

See ya in the next commit!
