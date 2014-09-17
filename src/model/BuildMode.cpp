#include "BuildMode.h"

namespace BuildModeEnum {

QString toString(int state) {
    if (Source == state) {
        return "Source";
    }
    if (SharedLocalLib == state) {
        return "SharedLocalLib";
    }
    if (SharedGlobalLib == state) {
        return "SharedGlobalLib";
    }
    if (SharedSystemLib == state) {
        return "SharedSystemLib";
    }
    return "AsItIs";
}

QString toString(BuildMode state) {
    if (Source == state) {
        return "Source";
    }
    if (SharedLocalLib == state) {
        return "SharedLocalLib";
    }
    if (SharedGlobalLib == state) {
        return "SharedGlobalLib";
    }
    if (SharedSystemLib == state) {
        return "SharedSystemLib";
    }
    return "AsItIs";
}

BuildMode fromString(QString state) {
    if (0 == QString::compare(state, "Source", Qt::CaseInsensitive)) {
        return Source;
    }
    if (0 == QString::compare(state, "SharedLocalLib", Qt::CaseInsensitive)) {
        return SharedLocalLib;
    }
    if (0 == QString::compare(state, "SharedGlobalLib", Qt::CaseInsensitive)) {
        return SharedGlobalLib;
    }
    if (0 == QString::compare(state, "SharedSystemLib", Qt::CaseInsensitive)) {
        return SharedSystemLib;
    }
    return AsItIs;
}

BuildMode fromInt(int state) {
    if (0 == state) {
        return Source;
    }
    if (1 == state) {
        return SharedLocalLib;
    }
    if (2 == state) {
        return SharedGlobalLib;
    }
    if (3 == state) {
        return SharedSystemLib;
    }
    return AsItIs;
}

BuildMode fromVariant(QVariant mode)
{
    if (mode.type() == QVariant::Int || mode.type() == QVariant::Double) {
        return fromInt(mode.toInt());
    }
    return fromString(mode.toString());
}

}
