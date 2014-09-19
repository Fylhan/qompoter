#ifndef QOMPOTER_GITLOADER_H
#define QOMPOTER_GITLOADER_H

#include "ILoader.h"

namespace Qompoter {
class GitLoader : public ILoader
{
    Q_OBJECT
public:
    GitLoader(const Query &query, QObject *parent=0);

    QString getLoadingType() const;
    bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
    QList<RequireInfo> loadDependencies(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo, bool &downloaded);
    bool load(const PackageInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
};
}

#endif // QOMPOTER_GITLOADER_H
