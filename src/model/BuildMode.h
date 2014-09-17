#ifndef BUILDMODE_H
#define BUILDMODE_H

#include <QString>
#include <QVariant>

namespace BuildModeEnum {
    enum BuildMode {
        AsItIs, /** Default if a builder is defined for this package. Use the builder of this package. */
        Source, /** Generate a builder for the sources, and let the project build it when it compiles itself */
        SharedLocalLib, /** Default if there is no builder defined for this package. Build using a generated builder: the resulting library and include files will be installed locally to the project. */
        SharedGlobalLib, /** Build using a generated builder: the resulting library and include files will be installed on the system and available to all projects. */
        SharedSystemLib, /** Retrieve the package and install the lib from the system package manager. E.g. apt-get install ... */
    };

    QString toString(int mode);
    QString toString(BuildMode mode);
    BuildMode fromString(QString mode);
    BuildMode fromVariant(QVariant mode);
    BuildMode fromInt(int mode);
}

#endif // BUILDMODE_H
