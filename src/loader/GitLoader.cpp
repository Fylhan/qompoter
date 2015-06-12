#include "GitLoader.h"

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

Qompoter::GitLoader::GitLoader(const Query &query, QObject *parent) :
    ILoader(query, "git", parent),
    git_(query_)
{}

bool Qompoter::GitLoader::isAvailable(const RequireInfo &dependencyInfo, const RepositoryInfo &repositoryInfo) const
{
    // TODO Check if the version is really available in the repo
    if (dependencyInfo.isLibOnly()) {
        return false;
    }
    bool res = false;
    if (repositoryInfo.getUrl().startsWith("http")) {
        // TODO manage redirections if any
        QNetworkAccessManager manager;
        QNetworkRequest request(QUrl(dependencyInfo.getRepositoryPackagePath(repositoryInfo)));
        QNetworkReply *reply = manager.head(request);
        QEventLoop loop;
        QObject::connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
        QTimer::singleShot(2000, &loop, SLOT(quit()));
        loop.exec();
        if (!reply->isFinished()) {
            qCritical()<<"\t  Apparently can't reach the URL "<<dependencyInfo.getRepositoryPackagePath(repositoryInfo)<<" that quickly...";
            res = false;
        }
        else {
            res = (200 == reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt());
        }
        reply->deleteLater();
    }
    else {
        res = QDir(dependencyInfo.getRepositoryPackagePath(repositoryInfo)).exists();
    }
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Package "<<dependencyInfo.getRepositoryPackagePath(repositoryInfo)<<" available ? "<<res;
    }
    return res;
}

QList<Qompoter::RequireInfo> Qompoter::GitLoader::loadDependencies(const PackageInfo &packageInfo, bool &downloaded)
{
    // Check qompoter.json file remotely
    if (packageInfo.getRepository().getUrl().startsWith("http")) {
        QNetworkAccessManager manager;
        QUrl url(packageInfo.getRepositoryQompoterFilePath());
        QNetworkRequest request(url);
        QNetworkReply *reply = manager.get(request);
        QEventLoop loop;
        QObject::connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
        QTimer::singleShot(3000, &loop, SLOT(quit()));
        loop.exec();
        if (!reply->isFinished()) {
            qCritical()<<"Apparently can't reach the URL "<<url<<" that quickly...";
            reply->deleteLater();
            return QList<Qompoter::RequireInfo>();
        }
        // TODO manage redirections if any
        if (200 != reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt()) {
            qCritical()<<"\t  No qompoter.json file for this dependency";
            reply->deleteLater();
            return QList<Qompoter::RequireInfo>();
        }
        QByteArray data = reply->readAll();
        Config configFile(Config::parseContent(QString::fromUtf8(data)));
        reply->deleteLater();
        return configFile.getRequires();
    }
    // Local repo special Qompoter
    if (QFile(packageInfo.getRepositoryQompoterFilePath()).exists()) {
        Config configFile(Config::parseFile(packageInfo.getRepositoryQompoterFilePath()));
        return configFile.getRequires();
    }
    // No such but to load it now!
    qDebug()<<"\t  Load package immediatly to find the qompoter.json if any";
    if (load(packageInfo)) {
        downloaded = true;
        if (QFile(packageInfo.getWorkingDirQompoterFilePath(query_)).exists()) {
            Config configFile(Config::parseFile(packageInfo.getWorkingDirQompoterFilePath(query_)));
            return configFile.getRequires();
        }
    }
    qCritical()<<"\t  No qompoter.json file for this dependency";
    return QList<RequireInfo>();
}

bool Qompoter::GitLoader::load(const PackageInfo &packageInfo)
{
    QString packageSourcePath = packageInfo.getRepositoryPackagePath();
    QString packageDestPath = packageInfo.getWorkingDirPackageName(query_);
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Load package source "<<packageSourcePath<<" to "<<packageDestPath;
    }
    qDebug()<<"\t  Downloading from Git... ";
    bool done = false;
    if (!QFile(packageDestPath).exists()) {
        git_.cd(query_.getWorkingDir());
        done = git_.clone(packageSourcePath, packageDestPath, packageInfo.getVersion());
    }
    else {
        git_.cd(packageDestPath);
        done = git_.checkout(packageInfo.getVersion(), true);
    }
    if (packageInfo.isLibOnly()) {
        done *= moveLibrary(packageDestPath);
    }
    return done;
}
