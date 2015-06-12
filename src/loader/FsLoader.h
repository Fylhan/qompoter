#ifndef QOMPOTER_FSLOADER_H
#define QOMPOTER_FSLOADER_H

#include "ILoader.h"

namespace Qompoter {
class FsLoader : public ILoader
{
    Q_OBJECT
public:
    FsLoader(const Query &query, QObject *parent=0);

    bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
    QList<RequireInfo> loadDependencies(const PackageInfo &packageInfo, bool &downloaded);
    bool load(const PackageInfo &packageInfo);
};
}

#endif // QOMPOTER_FSLOADER_H
