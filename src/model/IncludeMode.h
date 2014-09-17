#ifndef INCLUDEMODE_H
#define INCLUDEMODE_H

#include <QString>
#include <QVariant>

namespace IncludeModeEnum {
    enum IncludeMode {
        AsItIs, /** Default if a builder is defined for this package. Don't reorganize headers, neither add specific include path. */
        Flat, /** All public headers are available in the same folder. Default if no builder is defined for the package. AsItIs is used, if the package builder is used. */
        KeepHierarchy /** All public headers are available in the same folder hierarchy as it was during build. AsItIs is used, if the package builder is used. */
    };

    QString toString(int mode);
    QString toString(IncludeMode mode);
    IncludeMode fromString(QString mode);
    IncludeMode fromVariant(QVariant mode);
    IncludeMode fromInt(int mode);
}

#endif // INCLUDEMODE_H
