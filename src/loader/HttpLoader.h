#ifndef QOMPOTER_HTTPLOADER_H
#define QOMPOTER_HTTPLOADER_H

#include <QProcess>
#include <QSharedPointer>

#include "ILoader.h"

namespace Qompoter {
class HttpLoader : public ILoader
{
    Q_OBJECT
public:
    HttpLoader(const Query &query, QObject *parent=0);

    bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
    QList<RequireInfo> loadDependencies(const PackageInfo &packageInfo, bool &downloaded);
    bool load(const PackageInfo &packageInfo);

private:
    QProcess *wgetProcess_;

    void addAuthentication(QStringList &targetArguments, const RepositoryInfo &repositoryInfo) const;
};
}

#endif // QOMPOTER_HTTPLOADER_H
