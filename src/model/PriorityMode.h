#ifndef PRIORITYMODEENUM_PRIORITYMODE_H
#define PRIORITYMODEENUM_PRIORITYMODE_H

#include <QString>
#include <QVariant>

class QDebug;

namespace PriorityModeEnum {
enum PriorityMode {
    LibFirst, /** Default behaviour: prioritise lib, hence use source */
    LibOnly, /** Use only lib */
    SrcOnly, /** Use only source files */
};

QString toString(int val);
QString toString(const PriorityMode &val);
QString toHumanString(int val);
QString toHumanString(const PriorityMode &val);
PriorityMode fromString(const QString &val);
PriorityMode fromInt(int val);
PriorityMode fromVariant(const QVariant &val);
QDebug operator<<(QDebug dbg, const PriorityMode &val);
}

#endif // PRIORITYMODEENUM_PRIORITYMODE_H
