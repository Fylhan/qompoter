#include "ILoader.h"

#include <QDebug>
#include <QDir>

Qompoter::ILoader::ILoader(const Qompoter::Query &query, const QString &loadingType, QObject *parent) :
    QObject(parent),
    query_(query),
    loadingType_(loadingType)
{}

void Qompoter::ILoader::setQuery(const Qompoter::Query &query)
{
    query_ = query;
}

const QString &Qompoter::ILoader::getLoadingType() const
{
    return loadingType_;
}

bool Qompoter::ILoader::moveLibrary(const QString &packageDestPath) const
{
    bool res = true;
    // TODO Move depending of the target
    res *= cpDir(packageDestPath+"/lib_linux_32", packageDestPath+"/../lib_linux_32", false);
    res *= cpDir(packageDestPath+"/lib_linux_64", packageDestPath+"/../lib_linux_64", false);
    res *= cpDir(packageDestPath+"/lib_windows_32", packageDestPath+"/../lib_windows_32", false);
    res *= cpDir(packageDestPath+"/lib_windows_64", packageDestPath+"/../lib_windows_64", false);
    return res;
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

bool Qompoter::cpDir(const QString &srcPath, const QString &dstPath, bool deleteExistingDest)
{
    if (deleteExistingDest) {
        rmDir(dstPath);
    }
    QDir parentDstDir(QFileInfo(dstPath).path());
    if (!parentDstDir.mkpath(QFileInfo(dstPath).fileName())) {
        qCritical()<<"Can't create dir "<<dstPath;
        return false;
    }
    
    QDir srcDir(srcPath);
    foreach(const QFileInfo &info, srcDir.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot)) {
        QString srcItemPath = srcPath + "/" + info.fileName();
        QString dstItemPath = dstPath + "/" + info.fileName();
        if (info.isDir()) {
            if (!cpDir(srcItemPath, dstItemPath)) {
                qCritical()<<"Can't copy "<<srcItemPath<<" to "<<dstItemPath;
                return false;
            }
        } else if (info.isFile()) {
            QFile::remove(dstItemPath);
            if (!QFile::copy(srcItemPath, dstItemPath)) {
                qCritical()<<"Can't copy "<<srcItemPath<<" to "<<dstItemPath;
                return false;
            }
        } else {
            qDebug() << "Unhandled item" << info.filePath() << "in cpDir";
        }
    }
    return true;
}
