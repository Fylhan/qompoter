#include "HttpLoader.h"

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QTimer>
#include <QProcess>
#include <QDir>
#include <QDebug>

#include "Config.h"
#include "ConfigFileManager.h"

Qompoter::HttpLoader::HttpLoader(const Query &query, QObject *parent) :
    ILoader(query, parent)
{
}

QString Qompoter::HttpLoader::getLoadingType() const
{
    return "git";
}

bool Qompoter::HttpLoader::isAvailable(const Qompoter::RequireInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const
{
    QNetworkAccessManager manager;
    QNetworkRequest request(QUrl(repositoryInfo.url()+packageInfo.getPackageName()));
    QNetworkReply *reply = manager.head(request);
    QEventLoop loop;
    QObject::connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    QTimer::singleShot(2000, &loop, SLOT(quit()));
    loop.exec();
    if (!reply->isFinished()) {
        qCritical()<<"Apparently can't reach the URL "<<repositoryInfo.url()+packageInfo.getPackageName()<<" that quickly...";
        reply->deleteLater();
        return false;
    }
    bool res = (200 == reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt());
    // TODO manage redirections if any
    reply->deleteLater();
    return res;
}

QList<Qompoter::RequireInfo> Qompoter::HttpLoader::loadDependencies(const Qompoter::RequireInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const
{
    // Check qompoter.json file remotely
    QNetworkAccessManager manager;
    QUrl url(repositoryInfo.url()+packageInfo.getPackageName()+"/qomposer.json");
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
    if (200 == reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt()) {
        QByteArray data = reply->readAll();
        Config configFile(ConfigFileManager::parseContent(QString::fromUtf8(data)));
        return configFile.requires();
    }
    reply->deleteLater();

    // No such but to load it now!
    qDebug()<<"\t  Load package immediatly to find the qompoter.json if any";
    if (load(packageInfo, repositoryInfo) && QFile(_query.getWorkingDir()+_query.getVendorDir()+packageInfo.getPackageName()+"/qompoter.json").exists()) {
        Config configFile(ConfigFileManager::parseFile(_query.getWorkingDir()+_query.getVendorDir()+packageInfo.getPackageName()+"/qompoter.json"));
        return configFile.requires();
    }
    qCritical()<<"\t  No qompoter.json file for this dependency";
    return QList<RequireInfo>();
}

bool Qompoter::HttpLoader::load(const Qompoter::RequireInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const
{
    QString packageDestPath = _query.getWorkingDir()+_query.getVendorDir()+packageInfo.getPackageName();
    QString packageSourcePath = repositoryInfo.url()+packageInfo.getPackageName();
    if (!isAvailable(packageInfo, repositoryInfo)) {
        qCritical()<<"\t  No such package: "<<packageSourcePath;
        return false;
    }
    // TODO check if the same version is already there (with hash...)
    //    if (QDir(_query.getWorkingDir()+_query.getVendorDir()+packageInfo.packageName()).exists()) {
    //        qDebug()<<"\t  Already there";
    //        return true;
    //    }
    qDebug()<<"\t  Downloading from remote... ";
    QProcess wgetProcess;
    wgetProcess.setWorkingDirectory(packageDestPath);
    QString wgetProgram = "wget";
    QStringList arguments;
    arguments <<packageSourcePath;
     // Do action
    wgetProcess.start(wgetProgram, arguments);
    bool updated = wgetProcess.waitForFinished();
    if (_query.isVerbose()) {
        qDebug()<<"\t  "<<wgetProcess.readAll();
    }
    wgetProcess.close();
    return updated;
}
