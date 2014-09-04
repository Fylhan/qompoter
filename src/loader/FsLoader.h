#ifndef QOMPOTER_FSLOADER_H
#define QOMPOTER_FSLOADER_H

#include "ILoader.h"

namespace Qompoter {
class FsLoader : public ILoader
{
public:
    FsLoader(const Query &query);

    QString getLoadingType() const;
    bool isAvailable(const DependencyInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
    bool load(const DependencyInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
};

bool rmDir(const QString &dirPath);
bool cpDir(const QString &srcPath, const QString &dstPath);
}

#endif // QOMPOTER_FSLOADER_H
