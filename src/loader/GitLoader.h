#ifndef QOMPOTER_GITLOADER_H
#define QOMPOTER_GITLOADER_H

#include "ILoader.h"

namespace Qompoter {
class GitLoader : public ILoader
{
public:
    GitLoader(const Query &query);

    QString getLoadingType() const;
    bool isAvailable(const DependencyInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
    QList<DependencyInfo> loadDependencies(const Qompoter::DependencyInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const;
    bool load(const DependencyInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
};
}

#endif // QOMPOTER_GITLOADER_H
