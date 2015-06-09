#include "FsLoader.h"

#include <QDir>
#include <QDebug>

#include "Config.h"
#include "PackageInfo.h"

using namespace Qompoter;

Qompoter::FsLoader::FsLoader(const Qompoter::Query &query, QObject *parent) :
    ILoader(query, "fs", parent)
{}

bool Qompoter::FsLoader::isAvailable(const RequireInfo &requireInfo, const RepositoryInfo &repositoryInfo) const
{
    bool res = QDir(requireInfo.getRepositoryPackagePath(repositoryInfo)).exists();
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Package "<<requireInfo.getRepositoryPackagePath(repositoryInfo)<<" available? "<<res;
    }
    return res;
}

QList<RequireInfo> Qompoter::FsLoader::loadDependencies(const PackageInfo &packageInfo, bool &/*downloaded*/)
{
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Search dependencies in package "<<packageInfo.getRepositoryQompoterFilePath();
    }
    if (!QFile(packageInfo.getRepositoryQompoterFilePath()).exists()) {
        qCritical()<<"\t  No qompoter.json file for this dependency";
        return QList<RequireInfo>();
    }
    Config subConfig(Config::parseFile(packageInfo.getRepositoryQompoterFilePath()));
    return subConfig.getRequires();
}

bool Qompoter::FsLoader::load(const PackageInfo &packageInfo) const
{
    QString packageSourcePath = packageInfo.getRepositoryPackagePath();
    QString packageDestPath = packageInfo.getWorkingDirPackageName(query_);
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Load package source "<<packageSourcePath<<" to "<<packageDestPath<<"";
    }
    if (packageInfo.isAlreadyDownloaded()) {
        qDebug() << "\t  Already there";
        return true;
    }
//    if (!isAvailable(packageInfo, packageInfo.getRepository())) {
//        qCritical()<<"\t  No such package: "<<packageSourcePath;
//        return false;
//    }
    qDebug()<<"\t  Downloading...";
    bool res = cpDir(packageSourcePath, packageDestPath);
    if (packageInfo.isLibOnly()) {
        res *= moveLibrary(packageDestPath);
    }
    return res;
}
