#include "GitsRepository.h"

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QTimer>
#include <QProcess>
#include <QDir>
#include <QDebug>

#include "Config.h"

using namespace Qompoter;

Qompoter::GitsRepository::GitsRepository(const Query &query, QObject *parent) :
    IRepository(query, "gits", parent),
    git_(query_),
    http_(query_)
{
}

bool Qompoter::GitsRepository::contains(const RequireInfo &dependencyInfo)
{
    if (dependencyInfo.isLibOnly()) {
        return false;
    }
    // TODO implement GitsRepo
    qDebug()<<"To be implemented";
//    bool res = inqludeDb_.contains(dependencyInfo.getProjectName());
//    if (res) {
//        // Search
//        QString type, url;
//        QVariantMap packageInfo = inqludeDb_.value(dependencyInfo.getProjectName()).toMap();
//        QVariantMap urlInfo;
//        if (packageInfo.contains("urls") && (urlInfo = packageInfo.value("url").toMap()).contains("vcs")) {
//            url = packageInfo.value("vcs").toString();
//            if (url.contains("git") || url.contains("bitbucket")) {
//                type = "git";
//            }
//            else if (url.contains("kde")) {
//                url = "http://anongit.kde.org/"+dependencyInfo.getProjectName();
//                type = "git";
//            }
//            else {
//                res = false;
//            }
//        }
//        if (!res && packageInfo.contains("packages") && (urlInfo = packageInfo.value("packages").toMap()).contains("source")) {
//            url = packageInfo.value("source").toString();
//            type = "http";
//        }
//        else {
//            res = false;
//        }
        
//        // If found: save
//        if (res) {
//            PackageInfo package(dependencyInfo, RepositoryInfo(type, url), 0);
//            packages_.insert(dependencyInfo.getPackageName(), package);
//        }
//    }
//    if (query_.isVerbose()) {
//        qDebug()<<"\t  ["<<loadingType_<<"] Package "<<dependencyInfo.getProjectName()<<" available ? "<<res;
//    }
//    return res;
    return false;
}
