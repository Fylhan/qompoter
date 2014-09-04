#include "GitLoader.h"

#include <QProcess>
#include <QDir>
#include <QDebug>

Qompoter::GitLoader::GitLoader(const Query &query) :
    ILoader(query)
{
}

QString Qompoter::GitLoader::getLoadingType() const
{
    return "git";
}

bool Qompoter::GitLoader::isAvailable(const Qompoter::DependencyInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const
{
    return QDir(repositoryInfo.url()+packageInfo.packageName()+".git").exists();
}

bool Qompoter::GitLoader::load(const Qompoter::DependencyInfo &packageInfo, const Qompoter::RepositoryInfo &repositoryInfo) const
{
    QString packageDestPath = _query.getWorkingDir()+_query.getVendorDir()+packageInfo.packageName();
    QString packageSourcePath = repositoryInfo.url()+packageInfo.packageName()+".git";
    if (!isAvailable(packageInfo, repositoryInfo)) {
        qCritical()<<"\tNo such package: "<<packageSourcePath;
        return false;
    }
    qDebug()<<"\tDownloading from Git...";
    QProcess gitProcess;
    QString gitProgram = "git";
    QStringList arguments;
    // Install
    if (!QDir(packageDestPath+"/.git").exists()) {
        QDir workingDir(_query.getWorkingDir());
        workingDir.mkpath(_query.getVendorDir()+packageInfo.packageName());
        arguments << "clone" << packageSourcePath << packageDestPath;
    }
    // Update
    else {
        gitProcess.setWorkingDirectory(packageDestPath);
        arguments << "pull";
    }
    // Do action
    gitProcess.start(gitProgram, arguments);
    bool updated = gitProcess.waitForFinished();
    if (_query.isVerbose()) {
        qDebug()<<"\t"<<gitProcess.readAll();
    }
    // If version:
    /*
     * git tag -> is tag ? git checkout tag
     * git branch -> is branch "master" ? git checkout master (more precisely git checkout <commit> quand on aura qompoter.lock)
     */
    // Tag version
    gitProcess.start(gitProgram, QStringList()<<"tag");
    if (!gitProcess.waitForFinished()) {
        qCritical()<<"Can't' retrieve versions: "<<gitProcess.readAll();
    }
    else {
        //gitProcess.readLine();
        QByteArray tags = gitProcess.readAll();
        if (_query.isVerbose()) {
            qDebug()<<"\tAvailable tags: "<<tags;
        }
        if (tags.contains(QString("v"+packageInfo.version()).toLatin1())) {
            gitProcess.start(gitProgram, QStringList()<<"checkout"<<"v"+packageInfo.version());
            if (!gitProcess.waitForFinished()) {
                qCritical()<<"Can't' update to version "<<packageInfo.version()<<": "<<gitProcess.readAll();
            }
        }
        else {
            qCritical()<<"\tWarning: Version"<<packageInfo.version()<<"not found. Use dev-master instead.";
        }
    }
    // Branch version
    gitProcess.close();
    return updated;
}
