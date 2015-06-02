#include "HttpLoader.h"

#include <QDir>
#include <QDebug>

#include "Config.h"
#include "RequireInfo.h"

using namespace Qompoter;

HttpLoader::HttpLoader(const Query &query, QObject *parent)
    : ILoader(query, parent) {
    wgetProcess_ = new QProcess(this);
    wgetProcess_->setProgram("wget");
    wgetProcess_->setProcessChannelMode(QProcess::MergedChannels);
}

QString HttpLoader::getLoadingType() const { return "http"; }

bool HttpLoader::isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const {
    QString packageSourcePath = repositoryInfo.getUrl() + packageInfo.getPackageName() + ".zip";
    QStringList arguments;
    arguments<<"--spider"<<"-v";
    addAuthentication(arguments, repositoryInfo);
    arguments << packageSourcePath;
    if (query_.isVerbose()) {
        qDebug()<<"\t  "<<wgetProcess_->program() << arguments.join(" ");
    }
    wgetProcess_->setArguments(arguments);
    wgetProcess_->start();
    if (!wgetProcess_->waitForStarted()) {
        qCritical()<<"\t  Can't launch the command";
        return false;
    }
    bool found = false;
    QString stdout;
    if (wgetProcess_->waitForFinished()) {
        stdout = wgetProcess_->readAll();
        if (!stdout.contains("Échec", Qt::CaseInsensitive) &&
                !stdout.contains("Faillure", Qt::CaseInsensitive) &&
                !stdout.contains("Aucun", Qt::CaseInsensitive) &&
                !stdout.contains("No", Qt::CaseInsensitive)) {
            found = true;
        }
    } else {
        stdout = wgetProcess_->errorString();
    }
    if (query_.isVerbose()) {
        qDebug() << "\t  " << stdout;
    }
    wgetProcess_->close();
    return found;
}

QList<RequireInfo> HttpLoader::loadDependencies(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo, bool &downloaded) {
    // Check qompoter.json file remotely
    QString packageSourcePath = repositoryInfo.getUrl()+"/"+packageInfo.getPackageName()+"/qompoter.json";
    QString packageDestPath = query_.getVendorPath()+packageInfo.getPackageName();
    QStringList arguments;
    addAuthentication(arguments, repositoryInfo);
    arguments << packageSourcePath;
    arguments << "-o" << packageDestPath + "/qompoter.json";
    if (query_.isVerbose()) {
        qDebug() << wgetProcess_->program() << arguments.join(" ");
    }
    wgetProcess_->setWorkingDirectory(packageDestPath);
    wgetProcess_->setArguments(arguments);
    wgetProcess_->start();
    if (!wgetProcess_->waitForStarted()) {
        qCritical() << "\t  Can't launch the command";
        return QList<RequireInfo>();
    }
    bool found = false;
    QString stdout;
    if (wgetProcess_->waitForFinished()) {
        stdout = wgetProcess_->readAll();
        if (!stdout.contains("Échec", Qt::CaseInsensitive) &&
                !stdout.contains("Faillure", Qt::CaseInsensitive) &&
                !stdout.contains("Aucun", Qt::CaseInsensitive) &&
                !stdout.contains("No", Qt::CaseInsensitive)) {
            found = true;
        }
    } else {
        stdout = wgetProcess_->errorString();
    }
    if (query_.isVerbose()) {
        qDebug() << "\t  " << stdout;
    }
    wgetProcess_->close();
    if (found) {
        Config configFile(
                    Config::parseFile(packageDestPath + "/qompoter.json"));
        return configFile.requires();
    }
    
    // No such but to load it now!
    qDebug() << "\t  Load package immediatly to find the qompoter.json if any";
    if (load(PackageInfo(packageInfo, repositoryInfo, this), repositoryInfo) &&
            QFile(query_.getWorkingDir() + query_.getVendorDir() +
                  packageInfo.getPackageName() + "/qompoter.json").exists()) {
        downloaded = true;
        Config configFile(Config::parseFile(
                              query_.getWorkingDir() + query_.getVendorDir() +
                              packageInfo.getPackageName() + "/qompoter.json"));
        return configFile.requires();
    }
    qCritical() << "\t  No qompoter.json file for this dependency";
    return QList<RequireInfo>();
}

bool HttpLoader::load(const PackageInfo &packageInfo,
                      const RepositoryInfo &repositoryInfo)
const {
    QString packageDestPath = query_.getWorkingDir() + query_.getVendorDir() +
                              packageInfo.getPackageName();
    QString packageSourcePath =
            repositoryInfo.getUrl() + packageInfo.getPackageName() + ".zip";
    if (!isAvailable(packageInfo, repositoryInfo)) {
        qCritical() << "\t  No such package: " << packageSourcePath;
        return false;
    }
    // TODO check if the same version is already there (with hash...)
    // if (QDir(_query.getWorkingDir()+_query.getVendorDir()+packageInfo.packageName()).exists())
    // {}
    if (packageInfo.isAlreadyDownloaded()) {
        qDebug() << "\t  Already there";
        return true;
    }
    qDebug() << "\t  Downloading from remote... ";
    QStringList arguments;
    addAuthentication(arguments, repositoryInfo);
    arguments << packageSourcePath;
    QDir().mkpath(packageDestPath);
    //    arguments
    // <<"-o"<<packageDestPath+"/"+packageInfo.getProjectName()+".zip";
    // Do action
    if (query_.isVerbose()) {
        qDebug() << wgetProcess_->program() << arguments.join(" ");
    }
    //    wgetProcess_->setWorkingDirectory(packageDestPath);
    wgetProcess_->setArguments(arguments);
    wgetProcess_->start();
    if (!wgetProcess_->waitForStarted()) {
        qCritical() << "\t  Can't launch the command";
        return false;
    }
    bool done = false;
    QString stdout;
    if (wgetProcess_->waitForFinished()) {
        stdout = wgetProcess_->readAll();
        if (!stdout.contains("Échec", Qt::CaseInsensitive) &&
                !stdout.contains("Faillure", Qt::CaseInsensitive) &&
                !stdout.contains("Aucun", Qt::CaseInsensitive) &&
                !stdout.contains("No", Qt::CaseInsensitive)) {
            done = true;
        }
    } else {
        stdout = wgetProcess_->errorString();
    }
    if (query_.isVerbose()) {
        qDebug() << "\t  " << stdout;
    }
    wgetProcess_->close();
    
    QProcess gzip;
    gzip.setWorkingDirectory(packageDestPath);
    gzip.setProcessChannelMode(QProcess::MergedChannels);
    gzip.start("unzip", QStringList()<<"-C"<<packageInfo.getProjectName()+".zip");
    done = false;
    stdout.clear();
    if (gzip.waitForFinished()) {
        stdout = gzip.readAll();
        if (!stdout.contains("Échec", Qt::CaseInsensitive) &&
                !stdout.contains("Faillure", Qt::CaseInsensitive) &&
                !stdout.contains("Aucun", Qt::CaseInsensitive) &&
                !stdout.contains("No", Qt::CaseInsensitive)) {
            done = true;
        }
    } else {
        stdout = gzip.errorString();
    }
    if (query_.isVerbose()) {
        qDebug() << "\t  " << stdout;
    }
    gzip.close();
    return done;
}

void HttpLoader::addAuthentication(
        QStringList &targetArguments,
        const RepositoryInfo &repositoryInfo) const {
    if (!repositoryInfo.getUsername().isEmpty()) {
        targetArguments << "--user=" + repositoryInfo.getUsername();
        if (!repositoryInfo.getUserpwd().isEmpty()) {
            targetArguments << "--password=" + repositoryInfo.getUserpwd();
        } else {
            targetArguments << "--ask-password";
        }
    }
}
