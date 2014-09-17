#include "IncludeMode.h"

namespace IncludeModeEnum {

QString toString(int state) {
    if (Flat == state) {
        return "Flat";
    }
    if (KeepHierarchy == state) {
        return "KeepHierarchy";
    }
    return "AsItIs";
}

QString toString(IncludeMode state) {
    if (Flat == state) {
        return "Flat";
    }
    if (KeepHierarchy == state) {
        return "KeepHierarchy";
    }
    return "AsItIs";
}

IncludeMode fromString(QString state) {
    if (0 == QString::compare(state, "Flat", Qt::CaseInsensitive)) {
        return Flat;
    }
    if (0 == QString::compare(state, "KeepHierarchy", Qt::CaseInsensitive)) {
        return KeepHierarchy;
    }
    return AsItIs;
}

IncludeMode fromInt(int state) {
    if (1 == state) {
        return Flat;
    }
    if (2 == state) {
        return KeepHierarchy;
    }
    return AsItIs;
}

IncludeMode fromVariant(QVariant mode)
{
    if (mode.type() == QVariant::Int || mode.type() == QVariant::Double) {
        return fromInt(mode.toInt());
    }
    return fromString(mode.toString());
}

}
