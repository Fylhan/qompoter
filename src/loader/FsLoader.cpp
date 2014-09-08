#include "FsLoader.h"

#include <QDebug>
#include <QDir>

Qompoter::FsLoader::FsLoader(const Qompoter::Query &query) :
    ILoader(query)
{

}

QString Qompoter::FsLoader::getLoadingType() const
{
    return "fs";
}

bool Qompoter::FsLoader::isAvailable(const Qompoter::DependencyInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const
{
    return QDir(repositoryInfo.url()+packageInfo.packageName()).exists();
}

bool Qompoter::FsLoader::load(const Qompoter::DependencyInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const
{
    QString packageDestPath = _query.getWorkingDir()+_query.getVendorDir()+packageInfo.packageName();
    QString packageSourcePath = repositoryInfo.url()+packageInfo.packageName();
    if (!isAvailable(packageInfo, repositoryInfo)) {
        qCritical()<<"\tNo such package: "<<packageSourcePath;
        return false;
    }
    qDebug()<<"\tDownloading... from "<<repositoryInfo.url();
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
