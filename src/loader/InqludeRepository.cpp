#include "InqludeRepository.h"

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QTimer>
#include <QProcess>
#include <QDir>
#include <QDebug>

#include "Config.h"
#include "PackageInfo.h"

using namespace Qompoter;

Qompoter::InqludeRepository::InqludeRepository(const Query &query, QObject *parent) :
    IRepository(query, "inqlude", parent),
    git_(query_),
    http_(query_)
{
    http_.load(QUrl("http://inqlude.org/inqlude-all.json"), "inqlude-all.json");
    inqludeDb_ = Config::parseFile(query_.getWorkingDir()+"inqlude-all.json");
}

bool Qompoter::InqludeRepository::contains(const RequireInfo &requireInfo)
{
    if (requireInfo.isLibOnly()) {
        return false;
    }
    bool res = inqludeDb_.contains(requireInfo.getProjectName());
    if (res) {
        QVariantMap packageInfo = inqludeDb_.value(requireInfo.getProjectName()).toMap();
        // Search
        QString type, url;
        QVariantMap urlInfo;
        if (packageInfo.contains("urls") && (urlInfo = packageInfo.value("url").toMap()).contains("vcs")) {
            url = packageInfo.value("vcs").toString();
            if (url.contains("git") || url.contains("bitbucket")) {
                type = "git";
            }
            else if (url.contains("kde")) {
                url = "http://anongit.kde.org/"+requireInfo.getProjectName();
                type = "git";
            }
            else {
                res = false;
            }
        }
        if (!res && packageInfo.contains("packages") && (urlInfo = packageInfo.value("packages").toMap()).contains("source")) {
            url = packageInfo.value("source").toString();
            type = "http";
        }
        else {
            res = false;
        }
        
        // If found: save
        if (res) {
            PackageInfo package(requireInfo, RepositoryInfo(type, url), 0);
            packages_.insert(requireInfo.getPackageName(), package);
        }
    }
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Package "<<requireInfo.getProjectName()<<" available ? "<<res;
    }
    return res;
}
