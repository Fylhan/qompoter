Command Line
============

Usage: qompoter [action] [ --repo <repo> | other options ]

## Actions

Select an action in: inqlude, install, export, require

Other actions are useful for digging into Qompoter: jsonh.

### inqlude

With the "--search" option, allows to search packages into the [inqlude repository](https://inqlude.org/).

With the "--minify" option, allows to minify a "inqlude-all.json" file into something easily usable by Qompoter. This can be used to update the inqlude cached repository of Qompoter.

Examples:

    # Search the "vogel/injeqt" package
    qompoter inqlude --search vogel/injeqt
    # Search the "vogel/injeqt" package but using another inqlude repository than the Qompoter cached one
    qompoter inqlude --search vogel/injeqt --inqlude-file /home/me/Downloads/inqlude-all.json
    # Minify the provided "inqlude-all.json" file
    qompoter inqlude --minify --inqlude-file /home/me/Downloads/inqlude-all.json

The other functionnalities are not implemented yet.

### install

Download and install locally (i.e. into a "vendor" directory) the packages listed as required into the "qompoter.json" file. Several options can be used to select another "qompoter.json" file, "vendor" directory, repository path or to specify to select only nominal or stable packages.

Examples:

    # Install all required packages
    qompoter install --repo /Project
    # Install only nominal required packages
    qompoter install --no-dev --repo /Project
    # Install only stable required packages
    qompoter install --stable-only --repo /Project
    # Install all required packages with specific options, and do not generate Qt specific stuff thanks to the "--no-qompote" option
    qompoter install --repo /Project --file myqompoter.json --vendor myvendor --no-qompote --no-color

### export

Exports the "vendor" directory as a dated archive.

Examples:

    # Export the "vendor" directory
    qompoter export
    # Export the directory called "myvendor"
    qompoter export --vendor-dir myvendor

The other functionnalities are not implemented yet.

### require

With the "--list" options, lists the required packages of a project.

Example:
    # List required dependencies of the project
    qompoter require --list
    # List required dependencies of "myqompoter.json" file
    qompoter require --list --file myqompoter.json

The other functionnalities are not implemented yet.

### jsonh

Dig into a JSON file using the [SON.sh](https://github.com/dominictarr/JSON.sh) tool used by Qompoter.

Example:

    qompoter jsonh --file myqompoter.json | grep "require"

## Options

    -d, --depth         Depth of the recursivity in the searching of subpackages [default = 10]

        --inqlude-file  Pick the provided file to search into the inqlude repository

    -f, --file          Pick another Qompoter file [default = qompoter.json]

        --force         Force the action
                        Supported action is: install

    -l, --list          List elements depending of the action
                        Supported action is: require

        --minify        Minify the provided file
                        Supported action is: inqlude

        --no-color      Do not enable color on output [default = false]

        --no-dev        Do not retrieve dev dependencies listed in "require-dev" [default = false]
                        Supported action is: install

        --no-qompote    Do not generate any Qompoter specific stuffs like qompote.pri and vendor.pri [default = false]
                        Supported action is: install

    -r, --repo          Select a repository path as a location for dependency research. It is used in addition of the "repositories" provided in
                        "qompoter.json".
                        E.g. "repo/repositories/<vendor name>/<project name>"
                        Supported action is: export, install

        --search        Search related packages in a repository
                        Supported action is: inqlude

        --stable-only   Do not select unstable versions [default = false]
                        E.g. If "v1.*" is given to Qompoter, it will select "v1.0.3" and not "v1.0.4-RC1"
                        Supported action is: install

        --vendor-dir    Pick another vendor directory [default = vendor]
                        Supported action is: export, install

    -V, --verbose       Enable more verbosity

    -h, --help          Display this help

    -v, --version       Display the version
