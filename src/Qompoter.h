#ifndef QOMPOTER_QOMPOTER_H
#define QOMPOTER_QOMPOTER_H

#include <QHash>
#include <QSharedPointer>

#include "Config.h"
#include "ILoader.h"
#include "IQompoter.h"

namespace Qompoter {
class Qompoter : public IQompoter
{
    Q_OBJECT
public:
    Qompoter(Query &query, QObject *parent=0);
   
    bool doAction(const QString &action);
    bool install();
    bool update();
    bool loadQompoterFile();

protected:
    bool searchRecursiveDependencies();
    bool installDependencies();
    bool generateQompotePri();
    bool generateVendorPri();
    bool buildDependencies();
    
private:
    Query &query_;
    Config config_;
    QHash<QString, QSharedPointer<ILoader>> loaders_;
};
}

#endif // QOMPOTER_QOMPOTER_H
