#include "IRepository.h"

Qompoter::IRepository::IRepository(const Qompoter::Query &query, const QString &loadingType, QObject *parent) :
    QObject(parent),
    query_(query),
    loadingType_(loadingType)
{}

void Qompoter::IRepository::setQuery(const Qompoter::Query &query)
{
    query_ = query;
}

const QString &Qompoter::IRepository::getLoadingType() const
{
    return loadingType_;
}

const Qompoter::PackageInfo Qompoter::IRepository::package(const Qompoter::RequireInfo &packageInfo)
{
    if (!packages_.contains(packageInfo.getPackageName())) {
        contains(packageInfo);
    }
    return packages_.value(packageInfo.getPackageName());
}
