#ifndef QOMPOTER_GITLOADER_H
#define QOMPOTER_GITLOADER_H

#include "ILoader.h"
#include "GitWrapper.h"

namespace Qompoter {
class GitLoader : public ILoader
{
    Q_OBJECT
public:
    GitLoader(const Query &query, QObject *parent=0);

    bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
    QList<RequireInfo> loadDependencies(const PackageInfo &packageInfo, bool &downloaded);
    bool load(const PackageInfo &packageInfo);

private:
    GitWrapper git_;
};
}

#endif // QOMPOTER_GITLOADER_H
