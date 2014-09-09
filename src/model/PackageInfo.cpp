#include "PackageInfo.h"

using namespace Qompoter;

PackageInfo::PackageInfo(const RequireInfo &parent, const RepositoryInfo &repository, ILoader *loader) :
    RequireInfo(parent),
    _repository(repository)
{
    _loader = loader;
}

const RepositoryInfo &PackageInfo::repository()
{
    return _repository;
}

void PackageInfo::setRepository(const RepositoryInfo &repository)
{
    _repository = repository;
}

ILoader *PackageInfo::loader()
{
    return _loader;
}

void PackageInfo::setLoader(Qompoter::ILoader *loader)
{
    _loader = loader;
}
