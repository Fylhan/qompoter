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
    return RequireInfo::getRepositoryPackagePath(repository_);
}

QString PackageInfo::getRepositoryQompoterFilePath() const
{
    if (repository_.isVcsType()) {
        if (repository_.getUrl().startsWith("https://github.com")) {
            return "https://raw.githubusercontent.com/"+getPackageName()+"/master/qomposer.json";
        }
    }
    return RequireInfo::getRepositoryPackagePath(repository_)+"/qompoter.json";
}

const bool &PackageInfo::isAlreadyDownloaded() const
{
    return alreadyDownloaded_;
}

void PackageInfo::setAlreadyDownloaded(const bool &alreadyDownloaded)
{
    alreadyDownloaded_ = alreadyDownloaded;
}
