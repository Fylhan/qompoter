#include "RawFsRepository.h"

#include <QDebug>
#include <QDir>

#include "PackageInfo.h"

using namespace Qompoter;

RawFsRepository::RawFsRepository(const Query &query, const QString &url, QObject *parent) :
    IRepository(query, QStringLiteral("raw-fs"), parent),
    git_(query_),
    url_(url)
{}

bool RawFsRepository::contains(const RequireInfo &requireInfo)
{
    // Git
    QString type(QStringLiteral("git"));
    QString url(url_+"/"+requireInfo.getPackageName()+".git");
    bool res = QDir(url).exists();
    // Copy from FS
    if (!res) {
        type = QStringLiteral("fs");
        url = url_+"/"+requireInfo.getPackagePath();
        res = QDir(url_+"/"+requireInfo.getPackagePath()).exists();
    }
    
    if (res) {
        PackageInfo package(requireInfo, RepositoryInfo(type, url), 0);
        packages_.insert(package.getPackageName(), package);
    }
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Package "<<requireInfo.getProjectName()<<" available? "<<res;
    }
    return res;
}

