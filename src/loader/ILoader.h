#ifndef QOMPOTER_ILOADER_H
#define QOMPOTER_ILOADER_H

#include <QObject>
#include <QString>

#include "Query.h"
namespace Qompoter {
    class RequireInfo;
    class PackageInfo;
}
#include "RepositoryInfo.h"

namespace Qompoter {
class ILoader : public QObject
{
    Q_OBJECT
public:
    ILoader(const Query &query, QObject *parent=0) : QObject(parent), query_(query) {}
    virtual ~ILoader() {}

    inline void setQuery(const Query &query) {
        query_ = query;
    }
    virtual QString getLoadingType() const = 0;
    virtual bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const = 0;
    virtual QList<RequireInfo> loadDependencies(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo, bool &downloaded) = 0;
    virtual bool load(const PackageInfo &packageInfo, const RepositoryInfo &repositoryInfo) const = 0;

protected:
    Query query_;
};
}

#endif // QOMPOTER_ILOADER_H
