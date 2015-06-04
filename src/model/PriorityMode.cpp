#include "PriorityMode.h"

#include <QDebug>

using namespace PriorityModeEnum;

QString PriorityModeEnum::toString(int val)
{
    if (LibFirst == val) {
        return "LibFirst";
    }
    if (LibOnly == val) {
        return "LibOnly";
    }
    if (SrcOnly == val) {
        return "SrcOnly";
    }
    return "Unknown";
}

QString PriorityModeEnum::toString(const PriorityMode &val)
{
    if (LibFirst == val) {
        return "LibFirst";
    }
    if (LibOnly == val) {
        return "LibOnly";
    }
    if (SrcOnly == val) {
        return "SrcOnly";
    }
    return "Unknown";
}

QString PriorityModeEnum::toHumanString(int val)
{
    if (LibFirst == val) {
        return "LibFirst";
    }
    if (LibOnly == val) {
        return "LibOnly";
    }
    if (SrcOnly == val) {
        return "SrcOnly";
    }
    return "Unknown";
}

QString PriorityModeEnum::toHumanString(const PriorityMode &val)
{
    if (LibFirst == val) {
        return "LibFirst";
    }
    if (LibOnly == val) {
        return "LibOnly";
    }
    if (SrcOnly == val) {
        return "SrcOnly";
    }
    return "Unknown";
}

PriorityMode PriorityModeEnum::fromString(const QString &val)
{
    if ("0" == val
            || 0 == QString::compare(val, "LibFirst", Qt::CaseInsensitive)) {
        return LibFirst;
    }
    if ("1" == val
            || 0 == QString::compare(val, "LibOnly", Qt::CaseInsensitive)) {
        return LibOnly;
    }
    if ("2" == val
            || 0 == QString::compare(val, "SrcOnly", Qt::CaseInsensitive)) {
        return SrcOnly;
    }
    return SrcOnly;
}

PriorityMode PriorityModeEnum::fromInt(int val)
{
    if (0 == val) {
        return LibFirst;
    }
    if (1 == val) {
        return LibOnly;
    }
    if (2 == val) {
        return SrcOnly;
    }
    return SrcOnly;
}

PriorityMode PriorityModeEnum::fromVariant(const QVariant &val)
{
    if (val.type() == QVariant::Int || val.type() == QVariant::Double) {
        return fromInt(val.toInt());
    }
    return fromString(val.toString());
}

QDebug PriorityModeEnum::operator<<(QDebug dbg, const PriorityMode &val)
{
    dbg.maybeSpace()<<toHumanString(val);
    return dbg;
}

