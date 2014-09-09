#ifndef QOMPOTER_ILOADER_H
#define QOMPOTER_ILOADER_H

#include <QObject>
#include <QString>

#include "Query.h"
#include "RequireInfo.h"
#include "RepositoryInfo.h"

namespace Qompoter {
class ILoader : public QObject
{
    Q_OBJECT
public:
    ILoader(const Query &query, QObject *parent=0) : QObject(parent), _query(query) {}
    virtual ~ILoader() {}

    inline void setQuery(const Query &query) {
        _query = query;
    }
    virtual QString getLoadingType() const = 0;
    virtual bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const = 0;
    virtual QList<RequireInfo> loadDependencies(const Qompoter::RequireInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const = 0;
    virtual bool load(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const = 0;

protected:
    Query _query;
};
}

#endif // QOMPOTER_ILOADER_H
