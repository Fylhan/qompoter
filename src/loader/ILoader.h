#ifndef QOMPOTER_ILOADER_H
#define QOMPOTER_ILOADER_H

#include <QString>

#include "Query.h"
#include "DependencyInfo.h"
#include "RepositoryInfo.h"

namespace Qompoter {
class ILoader
{
public:
    ILoader(const Query &query) : _query(query) {}
    virtual ~ILoader() {}

    inline void setQuery(const Query &query) {
        _query = query;
    }
    virtual QString getLoadingType() const = 0;
    virtual bool isAvailable(const DependencyInfo &packageInfo, const RepositoryInfo &repositoryInfo) const = 0;
    virtual bool load(const DependencyInfo &packageInfo, const RepositoryInfo &repositoryInfo) const = 0;

protected:
    Query _query;
};
}

#endif // QOMPOTER_ILOADER_H
