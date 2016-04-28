#ifndef QOMPOTER_MOCKLOADER_H
#define QOMPOTER_MOCKLOADER_H

#include "Config.h"
#include "ILoader.h"

namespace Qompoter {

class MockLoader : public ILoader
{
    Q_OBJECT
public:
    MockLoader(const Query &query, QObject *parent=0);
    
    bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
    QList<RequireInfo> loadDependencies(const PackageInfo &packageInfo, bool &downloaded);
    bool load(const PackageInfo &packageInfo);
    
public:
    void addPackage(const QString &packagePath, const Config &config);
    void removePackage(const QString &packagePath);
    
private:
    QHash<QString, Config> availablePackages_;
};
}

#endif // QOMPOTER_MOCKLOADER_H
