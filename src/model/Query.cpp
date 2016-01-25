#include "Query.h"

#include <QDir>

Qompoter::Query::Query() :
    verbose_(false),
    dev_(true),
    global_(false),
    maxRecurency_(10),
    qompoterFile_("qompoter.json"),
    vendorDir_("vendor/"),
    gitBin_("git"),
    wgetBin_("wget")
{
}

QString Qompoter::Query::toString(const QString &prefixe) const
{
    QString str;
    str.append(prefixe+"{\n");
    str.append(prefixe+"\"action\": \""+action_+"\",\n");
    str.append(prefixe+"\"verbose\": "+QString::number(verbose_)+",\n");
    str.append(prefixe+"\"global\": "+QString::number(global_)+",\n");
    str.append(prefixe+"\"dev\": "+QString::number(dev_)+",\n");
    str.append(prefixe+"\"maxRecurency\": "+QString::number(maxRecurency_)+",\n");
    str.append(prefixe+"\"qompoterFile\": \""+qompoterFile_+"\",\n");
    str.append(prefixe+"\"workingDir\": \""+workingDir_+"\",\n");
    str.append(prefixe+"\"vendorDir\": \""+vendorDir_+"\",\n");
    str.append(prefixe+"\"repositories\": [\n");
    foreach(RepositoryInfo repository, repositories_) {
        str.append(repository.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"\"gitBin\": \""+gitBin_+"\",\n");
    str.append(prefixe+"\"wgetBin\": \""+wgetBin_+"\"\n");
    str.append(prefixe+"}");
    return str;
}

const QString &Qompoter::Query::getAction() const
{
    return action_;
}
void Qompoter::Query::setAction(const QString &action)
{
    action_ = action;
}

const bool &Qompoter::Query::isVerbose() const
{
    return verbose_;
}
void Qompoter::Query::setVerbose(const bool &verbose)
{
    verbose_ = verbose;
}

const bool &Qompoter::Query::isGlobal() const
{
    return global_;
}

void Qompoter::Query::setGlobal(const bool &global)
{
    global_ = global;
}

const bool &Qompoter::Query::isDev() const
{
    return dev_;
}

void Qompoter::Query::setDev(const bool &dev)
{
    dev_ = dev;
}

const int &Qompoter::Query::getMaxRecurency() const
{
    return maxRecurency_;
}

void Qompoter::Query::setMaxRecurency(const int &maxRecurency)
{
    maxRecurency_ = maxRecurency;
}

const QString &Qompoter::Query::getQompoterFile() const
{
    return qompoterFile_;
}
void Qompoter::Query::setQompoterFile(const QString &qompoterFile)
{
    qompoterFile_ = qompoterFile;
}

QString Qompoter::Query::getQompoterFilePath() const
{
    return workingDir_+qompoterFile_;
}

QString Qompoter::Query::getVendorPath() const
{
    return workingDir_+vendorDir_;
}

const QString &Qompoter::Query::getWorkingDir() const
{
    return workingDir_;
}
void Qompoter::Query::setWorkingDir(const QString &workingDir)
{
    workingDir_ = workingDir+("" != workingDir && !workingDir.endsWith("/") ? "/" : "");
}

const QString &Qompoter::Query::getVendorDir() const
{
    return vendorDir_;
}
void Qompoter::Query::setVendorDir(const QString &vendorDir)
{
    vendorDir_ = vendorDir+("" != vendorDir && !vendorDir.endsWith("/") ? "/" : "");
    // - Check if folder exists
    if ("" != vendorDir && !QDir(vendorDir).exists()) {
        QDir().mkpath(vendorDir);
    }
}

const QList<Qompoter::RepositoryInfo> &Qompoter::Query::getRepositories() const
{
    return repositories_;
}

void Qompoter::Query::addRepositories(const QList<Qompoter::RepositoryInfo> &repositories)
{
    repositories_ = repositories;
}

void Qompoter::Query::addRepositories(const QStringList &repositories, const QString &repositoryType)
{
    foreach(QString repository, repositories) {
        repositories_.append(RepositoryInfo(repositoryType, repository));
    }
}

void Qompoter::Query::addRepository(const QString &repository, const QString &repositoryType)
{
    repositories_.append(RepositoryInfo(repositoryType, repository));
}

void Qompoter::Query::addRepository(const Qompoter::RepositoryInfo &repository)
{
    repositories_.append(repository);
}

const QString &Qompoter::Query::getGitBin() const
{
    return gitBin_;
}

void Qompoter::Query::setGitBin(const QString &gitBin)
{
    gitBin_ = gitBin;
}

const QString &Qompoter::Query::getWgetBin() const
{
    return wgetBin_;
}

void Qompoter::Query::setWgetBin(const QString &wgetBin)
{
    wgetBin_ = wgetBin;
}

