#include "PackageInfo.h"

using namespace Qompoter;

PackageInfo::PackageInfo(const RequireInfo &parent, const RepositoryInfo &repository, ILoader *loader, bool alreadyDownloaded) :
    RequireInfo(parent),
    repository_(repository),
    alreadyDownloaded_(alreadyDownloaded)
{
    loader_ = loader;
}

const RepositoryInfo &PackageInfo::getRepository() const
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

QString PackageInfo::getRepositoryPackagePath() const
{
    if (0 == loader_->getLoadingType().compare("git", Qt::CaseInsensitive)) {
        return repository_.getUrl()+"/"+getPackageName();
    }
    return repository_.getUrl()+"/"+getPackagePath();
}

const bool &PackageInfo::isAlreadyDownloaded() const
{
    return alreadyDownloaded_;
}

void PackageInfo::setAlreadyDownloaded(const bool &alreadyDownloaded)
{
    alreadyDownloaded_ = alreadyDownloaded;
}
