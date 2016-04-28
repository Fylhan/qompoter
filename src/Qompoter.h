#ifndef QOMPOTER_QOMPOTER_H
#define QOMPOTER_QOMPOTER_H

#include <QHash>
#include <QSharedPointer>

#include "Config.h"
#include "ILoader.h"
#include "IQompoter.h"
#include "IRepository.h"

namespace Qompoter {
class Qompoter : public IQompoter
{
    Q_OBJECT
public:
    Qompoter(Query &query, QObject *parent=0);
   
    bool doAction(const QString &action);
    bool install();
    bool update();
    Config loadQompoterFile(const QString &qompoterFilePath, bool *ok=0);
    const QHash<QString, PackageInfo> &install1Qompoter(const QString &qompoterFilePath, bool main, bool *ok=0);
    
    const Config &getConfig() const;
    const Query &getQuery() const;
    void setQuery(const Query &query);

protected:
    bool searchAndLoadPackages(Config &config, bool dev=false);
    bool load(PackageInfo &packageInfo);
    bool installDependencies();
    bool generateQompotePri();
    bool generateVendorPri();
    bool buildDependencies();
    
private:
    Query &query_;
    Config config_;
    QHash<QString, QSharedPointer<ILoader>> loaders_;
    QHash<QString, QSharedPointer<IRepository>> repos_;
    QHash<QString, PackageInfo> packages_;
};
}

#endif // QOMPOTER_QOMPOTER_H
