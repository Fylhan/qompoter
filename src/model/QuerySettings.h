#ifndef QOMPOTER_QUERYSETTINGS_H
#define QOMPOTER_QUERYSETTINGS_H

#include <QObject>

class QSettings;
namespace Qompoter {
class Query;
}

namespace Qompoter {
class QuerySettings: QObject
{
    Q_OBJECT
public:
    QuerySettings(QSettings &settings, Query &query);

    void loadSettings();

private:
    QSettings &settings_;
    Query &query_;
};
}

#endif // QOMPOTER_QUERYSETTINGS_H
