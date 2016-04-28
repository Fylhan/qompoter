#include "MockLoader.h"

#include <QDebug>

#include "Config.h"
#include "PackageInfo.h"

using namespace Qompoter;

MockLoader::MockLoader(const Qompoter::Query &query, QObject *parent) :
    ILoader(query, "mock", parent)
{}

bool MockLoader::isAvailable(const RequireInfo &requireInfo, const RepositoryInfo &repositoryInfo) const
{
    bool res = availablePackages_.contains(requireInfo.getRepositoryPackagePath(repositoryInfo));
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Package "<<requireInfo.getRepositoryPackagePath(repositoryInfo)<<" available? "<<res;
    }
    return res;
}

QList<RequireInfo> MockLoader::loadDependencies(const PackageInfo &packageInfo, bool &/*downloaded*/)
{
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Search dependencies in package "<<packageInfo.getRepositoryQompoterFilePath();
    }
    if (availablePackages_.contains(packageInfo.getRepositoryPackagePath())) {
        return availablePackages_.value(packageInfo.getRepositoryPackagePath()).getRequires();
    }
    qCritical()<<"\t  No qompoter.json file for this dependency";
    return QList<RequireInfo>();
}

bool MockLoader::load(const PackageInfo &packageInfo)
{
    QString packageSourcePath = packageInfo.getRepositoryPackagePath();
    QString packageDestPath = packageInfo.getWorkingDirPackageName(query_);
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Load package source "<<packageSourcePath<<" to "<<packageDestPath<<"";
    }
    qDebug()<<"\t  Downloading...";
    return true;
}

void MockLoader::addPackage(const QString &packagePath, const Config &config)
{
    availablePackages_.insert(packagePath, config);
}

void MockLoader::removePackage(const QString &packagePath)
{
    availablePackages_.remove(packagePath);
}
