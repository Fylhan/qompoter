#include "FsLoader.h"

#include <QDebug>
#include <QDir>

#include "Config.h"
#include "PackageInfo.h"

using namespace Qompoter;

Qompoter::FsLoader::FsLoader(const Qompoter::Query &query, QObject *parent) :
    ILoader(query, parent)
{
}

QString Qompoter::FsLoader::getLoadingType() const
{
    return "fs";
}

bool Qompoter::FsLoader::isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const
{
    return QDir(repositoryInfo.getUrl()+packageInfo.getPackageName()).exists();
}

QList<RequireInfo> Qompoter::FsLoader::loadDependencies(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo, bool &/*downloaded*/)
{
    QString qompoterFile = repositoryInfo.getUrl()+packageInfo.getPackageName()+"/qompoter.json";
    if (!QFile(qompoterFile).exists()) {
        qCritical()<<"\t  No qompoter.json file for this dependency";
        return QList<RequireInfo>();
    }
    Config subConfig(Config::parseFile(qompoterFile));
    return subConfig.requires();
}

bool Qompoter::FsLoader::load(const PackageInfo &packageInfo, const RepositoryInfo &repositoryInfo) const
{
    QString packageDestPath = _query.getWorkingDir()+_query.getVendorDir()+packageInfo.getPackageName();
    QString packageSourcePath = repositoryInfo.getUrl()+packageInfo.getPackageName();
    if (packageInfo.isAlreadyDownloaded()) {
      qDebug() << "\t  Already there";
      return true;
    }
    if (!isAvailable(packageInfo, repositoryInfo)) {
        qCritical()<<"\t  No such package: "<<packageSourcePath;
        return false;
    }
    qDebug()<<"\t  Downloading...";
    return Qompoter::cpDir(packageSourcePath, packageDestPath);
}

bool Qompoter::rmDir(const QString &dirPath)
{
    QDir dir(dirPath);
    if (!dir.exists())
        return true;
    foreach(const QFileInfo &info, dir.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot)) {
        if (info.isDir()) {
            if (!rmDir(info.filePath()))
                return false;
        } else {
            if (!dir.remove(info.fileName()))
                return false;
        }
    }
    QDir parentDir(QFileInfo(dirPath).path());
    return parentDir.rmdir(QFileInfo(dirPath).fileName());
}

bool Qompoter::cpDir(const QString &srcPath, const QString &dstPath)
{
    rmDir(dstPath);
    QDir parentDstDir(QFileInfo(dstPath).path());
    if (!parentDstDir.mkpath(QFileInfo(dstPath).fileName()))
        return false;

    QDir srcDir(srcPath);
    foreach(const QFileInfo &info, srcDir.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot)) {
        QString srcItemPath = srcPath + "/" + info.fileName();
        QString dstItemPath = dstPath + "/" + info.fileName();
        if (info.isDir()) {
            if (!cpDir(srcItemPath, dstItemPath)) {
                return false;
            }
        } else if (info.isFile()) {
            if (!QFile::copy(srcItemPath, dstItemPath)) {
                return false;
            }
        } else {
            qDebug() << "Unhandled item" << info.filePath() << "in cpDir";
        }
    }
    return true;
}