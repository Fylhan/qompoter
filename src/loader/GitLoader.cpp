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
    ILoader(query, "git", parent)
{}

bool Qompoter::GitLoader::isAvailable(const RequireInfo &dependencyInfo, const RepositoryInfo &repositoryInfo) const
{
    // TODO Check if the version is really available in th repo
    if (dependencyInfo.isLibOnly()) {
        return false;
    }
    bool res = false;
    if (repositoryInfo.getUrl().startsWith("http")) {
        // TODO manage redirections if any
        QNetworkAccessManager manager;
        QNetworkRequest request(QUrl(repositoryInfo.getUrl()+"/"+dependencyInfo.getPackageName()));
        QNetworkReply *reply = manager.head(request);
        QEventLoop loop;
        QObject::connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
        QTimer::singleShot(2000, &loop, SLOT(quit()));
        loop.exec();
        if (!reply->isFinished()) {
            qCritical()<<"Apparently can't reach the URL "<<repositoryInfo.getUrl()+"/"+dependencyInfo.getPackageName()<<" that quickly...";
            res = false;
        }
        else {
            res = (200 == reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt());
        }
        reply->deleteLater();
    }
    else {
        res = QDir(repositoryInfo.getUrl()+"/"+dependencyInfo.getPackageName()+"/"+dependencyInfo.getProjectName()+".git").exists();
    }
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Package "<<repositoryInfo.getUrl()+"/"+dependencyInfo.getPackageName()+"/"+dependencyInfo.getProjectName()+".git"<<" available ? "<<res;
    }
    return res;
}

QList<Qompoter::RequireInfo> Qompoter::GitLoader::loadDependencies(const PackageInfo &packageInfo, bool &downloaded)
{
    // Check qompoter.json file remotely
    if (packageInfo.getRepository().getUrl().startsWith("http")) {
        // Github
        if (packageInfo.getRepository().getUrl().startsWith("https://github.com")) {
            QNetworkAccessManager manager;
            QUrl url("https://raw.githubusercontent.com/"+packageInfo.getPackageName()+"/master/qomposer.json");
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
            return configFile.requires();
        }
    }
    // Local repo special Qompoter
    if (QFile(packageInfo.getRepositoryPackagePath()+".git/qompoter.json").exists()) {
        Config configFile(Config::parseFile(packageInfo.getRepositoryPackagePath()+".git/qompoter.json"));
        return configFile.requires();
    }
    // No such but to load it now!
    qDebug()<<"\t  Load package immediatly to find the qompoter.json if any";
    if (load(packageInfo)) {
        downloaded = true;
        if (QFile(packageInfo.getWorkingDirPackageName(query_)+"/qompoter.json").exists()) {
            Config configFile(Config::parseFile(packageInfo.getWorkingDirPackageName(query_)+"/qompoter.json"));
            return configFile.requires();
        }
    }
    qCritical()<<"\t  No qompoter.json file for this dependency";
    return QList<RequireInfo>();
}

bool Qompoter::GitLoader::load(const PackageInfo &packageInfo) const
{
    QString packageSourcePath = packageInfo.getRepositoryPackagePath()+"/"+packageInfo.getProjectName()+".git";
    QString packageDestPath = packageInfo.getWorkingDirPackageName(query_);
    if (query_.isVerbose()) {
        qDebug()<<"\t  ["<<loadingType_<<"] Load package source "<<packageSourcePath<<" to "<<packageDestPath<<"";
    }
//    if (!isAvailable(packageInfo, packageInfo.getRepository())) {
//        qCritical()<<"\t  No such package: "<<packageSourcePath;
//        return false;
//    }
    // TODO check if the same version is already there (with hash...)
    //    if (QDir(_query.getWorkingDir()+_query.getVendorDir()+packageInfo.packageName()).exists()) {
    //        qDebug()<<"\t  Already there";
    //        return true;
    //    }
    if (packageInfo.isAlreadyDownloaded()) {
        qDebug() << "\t  Already there";
        return true;
    }
    qDebug()<<"\t  Downloading from Git... ";
    QProcess gitProcess;
    QString gitProgram = "git";
    QStringList arguments;
    // Install
    //    if (!QDir(packageDestPath+"/.git").exists()) {
    //        QDir workingDir(query_.getWorkingDir());
    //        workingDir.mkpath(packageDestPath);
    arguments<<"clone"<<packageSourcePath<<"-b"<<packageInfo.getVersion()<<packageDestPath;
    //    }
    //    // Update
    //    else {
    //        gitProcess.setWorkingDirectory(packageDestPath);
    //        arguments << "pull";
    //    }
    // Do action
    gitProcess.setWorkingDirectory(query_.getWorkingDir());
    gitProcess.start(gitProgram, arguments);
    bool updated = gitProcess.waitForFinished();
    updated *= QProcess::NormalExit == gitProcess.exitStatus();
    if (query_.isVerbose()) {
        qDebug()<<"\t  "<<gitProcess.program()<<" "<<arguments;
        qDebug()<<"\t  "<<gitProcess.readAll();
        qDebug()<<"\t  Exit code: "<<gitProcess.exitCode();
    }
    // If version:
    /*
     * git tag -> is tag ? git checkout tag
     * git branch -> is branch "master" ? git checkout master (more precisely git checkout <commit> quand on aura qompoter.lock)
     */
    /*// Tag version
    gitProcess.start(gitProgram, QStringList()<<"tag");
    if (!gitProcess.waitForFinished()) {
        qCritical()<<"\t  Can't' retrieve versions: "<<gitProcess.readAll();
    }
    else {
        //gitProcess.readLine();
        QString tags = gitProcess.readAll();
        if (query_.isVerbose()) {
            qDebug()<<"\t  Available tags: "<<tags;
        }
        if (tags.contains(packageInfo.getVersion(), Qt::CaseInsensitive)) {
            gitProcess.start(gitProgram, QStringList()<<"checkout"<<"v"+packageInfo.getVersion());
            if (!gitProcess.waitForFinished()) {
                qCritical()<<"\t  Can't' update to version "<<packageInfo.getVersion()<<": "<<gitProcess.readAll();
            }
        }
        else {
            qCritical()<<"\t  Warning: Version "<<packageInfo.getVersion()<<" not found. Use dev-master instead.";
        }
    }*/
    // Branch version
    gitProcess.close();
    if (packageInfo.isLibOnly()) {
        updated *= moveLibrary(packageDestPath);
    }
    return updated;
}
