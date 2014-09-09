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
    QList<RequireInfo> loadDependencies(const Qompoter::RequireInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const;
    bool load(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
};
}

#endif // QOMPOTER_GITLOADER_H
