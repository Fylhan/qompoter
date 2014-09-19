#ifndef QOMPOTER_FSLOADER_H
#define QOMPOTER_FSLOADER_H

#include "ILoader.h"

namespace Qompoter {
class FsLoader : public ILoader
{
    Q_OBJECT
public:
    FsLoader(const Query &query, QObject *parent=0);

    QString getLoadingType() const;
    bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
    QList<RequireInfo> loadDependencies(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo, bool &downloaded);
    bool load(const PackageInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
};

bool rmDir(const QString &dirPath);
bool cpDir(const QString &srcPath, const QString &dstPath);
}

#endif // QOMPOTER_FSLOADER_H
