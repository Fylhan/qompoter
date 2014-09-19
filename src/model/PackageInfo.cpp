#include "PackageInfo.h"

using namespace Qompoter;

PackageInfo::PackageInfo(const RequireInfo &parent, const RepositoryInfo &repository, ILoader *loader, bool alreadyDownloaded) :
    RequireInfo(parent),
    repository_(repository),
    alreadyDownloaded_(alreadyDownloaded)
{
    loader_ = loader;
}

const RepositoryInfo &PackageInfo::repository()
{
    return repository_;
}

void PackageInfo::setRepository(const RepositoryInfo &repository)
{
    repository_ = repository;
}

ILoader *PackageInfo::loader()
{
    return loader_;
}

void PackageInfo::setLoader(Qompoter::ILoader *loader)
{
    loader_ = loader;
}

const bool &PackageInfo::isAlreadyDownloaded() const
{
    return alreadyDownloaded_;
}

void PackageInfo::setAlreadyDownloaded(const bool &alreadyDownloaded)
{
    alreadyDownloaded_ = alreadyDownloaded;
}
