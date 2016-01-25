#include "Qompoter.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QList>
#include <QMutableListIterator>
#include <QProcess>
#include <QStringList>

#include "FsLoader.h"
#include "GitLoader.h"
#include "HttpLoader.h"
#include "InqludeRepository.h"
#include "PackageInfo.h"
#include "Query.h"
#include "RawFsRepository.h"

using namespace Qompoter;

Qompoter::Qompoter::Qompoter(Query &query, QObject *parent) :
    IQompoter(parent),
    query_(query)
{
    loaders_.insert("git", QSharedPointer<ILoader>(new GitLoader(query)));
    loaders_.insert("fs", QSharedPointer<ILoader>(new FsLoader(query)));
    loaders_.insert("http", QSharedPointer<ILoader>(new HttpLoader(query)));
    repos_.insert("inqlude", QSharedPointer<IRepository>(new InqludeRepository(query)));
    repos_.insert("raw-fs", QSharedPointer<IRepository>(new RawFsRepository(query, QStringLiteral("/media/data/Project/qompoter"))));
}

bool Qompoter::Qompoter::doAction(const QString &action)
{
    if (0 == action.compare(QStringLiteral("install"), Qt::CaseInsensitive)) {
        if (query_.isVerbose()) {
            qDebug()<<"Install\n";
        }
        return install();
    }
    if (0 == action.compare(QStringLiteral("update"), Qt::CaseInsensitive)) {
        if (query_.isVerbose()) {
            qDebug()<<"Update\n";
        }
        return update();
    }
    qCritical()<<"Unknown action";
    return false;
}

bool Qompoter::Qompoter::install()
{
    bool res = false;
    qDebug()<<"Loading qompoter repositories with package information";
    QHash<QString, PackageInfo> packages = install1Qompoter(query_.getQompoterFilePath(), true, &res);
    if (!res) {
        return false;
    }
    for (int i=0; i<query_.getMaxRecurency(); ++i) {
        QHash<QString, PackageInfo> subPackages;
        foreach(PackageInfo packageInfo, packages.values()) {
            subPackages.unite(install1Qompoter(packageInfo.getWorkingDirQompoterFilePath(query_), false, &res));
        }
        packages = subPackages;
        if (query_.getMaxRecurency()-1 == i && subPackages.size() > 0) {
            qWarning()<<"Still at least"<<subPackages.size()<<"packages to load , but max reccurency of"<<query_.getMaxRecurency()<<"reached.";
        }
    }
    if (query_.isVerbose()) {
        qDebug()<<"Generating qompoter.pri\n";
    }
    res *= generateQompotePri();
    res *= generateVendorPri();
    return res;
}

bool Qompoter::Qompoter::update()
{
    return install();
}

const QHash<QString, PackageInfo> &Qompoter::Qompoter::install1Qompoter(const QString &qompoterFilePath, bool main, bool *ok)
{
    bool res = false;
    Config config = loadQompoterFile(qompoterFilePath, &res);
    if (res) {
        if (main) {
            qDebug()<<"Installing dependencies...";
            config_ = config;
        }
        res = searchAndLoadPackages(config, (main ? query_.isDev() : false));
    }
    if (0 != ok) {
        *ok = res;
    }
    return config.getPackages();
}

Config Qompoter::Qompoter::loadQompoterFile(const QString &qompoterFilePath, bool *ok)
{
    bool res = false;
    qDebug()<<"Parsing "<<qompoterFilePath<<"...";
    Config config = Config::fromFile(qompoterFilePath, &res);
    if (res) {
        config.addRepositories(query_.getRepositories());
    }
    if (0 != ok) {
        *ok = res;
    }
    return config;
}

const Config &Qompoter::Qompoter::getConfig() const
{
    return config_;
}

const Query &Qompoter::Qompoter::getQuery() const
{
    return query_;
}

void Qompoter::Qompoter::setQuery(const Query &query)
{
    query_ = query;
}

bool Qompoter::Qompoter::searchAndLoadPackages(Config &config, bool dev)
{
    QList<RequireInfo> dependencies = config.getRequires();
    if (dev) {
        dependencies.append(config.getRequireDev());
    }
    // Search package information
    bool globalResult = true;
    foreach (RequireInfo requireInfo, dependencies) {
        if (!requireInfo.isDownloadRequired() || config_.hasPackage(requireInfo.getPackageName())) {
            qDebug()<<"Already donwloaded";
            continue;
        }
        qDebug()<<"";
        qDebug()<<"\t- Installing"<<requireInfo.getPackageName()<<" ("<<requireInfo.getVersion()<<")";
        bool found = false;
        PackageInfo package;
        foreach (QSharedPointer<IRepository> repo, repos_) {
            // Prioritise lib first
            if (requireInfo.isLibFirst()) {
                QString originalVersionNb = requireInfo.getVersion();
                requireInfo.setVersion(originalVersionNb+"-lib");
                if (repo->contains(requireInfo)) {
                    found = true;
                    package = repo->package(requireInfo);
                    break;
                }
                requireInfo.setVersion(originalVersionNb);
            }
            // If priority already defined, or if lib not available
            if (repo->contains(requireInfo)) {
                found = true;
                package = repo->package(requireInfo);
                break;
            }
        }
        globalResult *= found;
        if (!found) {
            qCritical()<<"\t  Package not found";
        }
        else {
            load(package);
            config.addPackage(package);
        }
    }
    qDebug()<<"";
    return globalResult;
}

bool Qompoter::Qompoter::load(PackageInfo &packageInfo)
{
    if (!packageInfo.isDownloadRequired() || packageInfo.isAlreadyDownloaded()) {
        return true;
    }
    if(!loaders_.contains(packageInfo.getRepository().getType())) {
        qCritical()<<"\t  Can't download this package";
        if (query_.isVerbose()) {
            qCritical()<<"\t  No loader for repository type:"<<packageInfo.getRepository().getType();
        }
        return false;
    }
    QSharedPointer<ILoader> loader = loaders_.value(packageInfo.getRepository().getType());
    if (loader->load(packageInfo)) {
        packageInfo.setAlreadyDownloaded(true);
        qDebug()<<"\t  done";
        return true;
    }
    qCritical()<<"\t  FAILLURE";
    return false;
}

bool Qompoter::Qompoter::installDependencies()
{
    bool globalResult = true;
    //    foreach (PackageInfo packageInfo, config_.getPackages()) {
    //        if (!packageInfo.isDownloadRequired()) {
    //            continue;
    //        }
    //        bool found = false;
    //        bool updated = false;
    //        qDebug()<<"\t- Installing:"<<packageInfo.getPackageName()<<" ("<<packageInfo.getVersion()<<")";
    //        if (packageInfo.isAlreadyDownloaded()) {
    //            qDebug() << "\t  Already there";
    //            found = true;
    //            updated = true;
    //        }
    //        if (!found && 0 != packageInfo.loader() && packageInfo.loader()->isAvailable(packageInfo, packageInfo.getRepository())) {
    //            found = true;
    //            updated = packageInfo.loader()->load(packageInfo);
    //        }
    //        if (updated) {
    //            qDebug()<<"\t  done";
    //        }
    //        else if (!found)
    //            qCritical()<<"\t  FAILLURE: not found package";
    //        else
    //            qCritical()<<"\t  FAILLURE";
    //        qDebug()<<"";
    //        globalResult *= updated;
    //    }
    return globalResult;
}

bool Qompoter::Qompoter::generateQompotePri()
{
    return QFile(":pri/qompote.pri").copy(query_.getVendorPath()+"qompote.pri");
}

bool Qompoter::Qompoter::generateVendorPri()
{
    QFile vendorPriFile(query_.getVendorPath()+"vendor.pri");
    vendorPriFile.remove();
    if (!vendorPriFile.open(QFile::ReadWrite | QFile::Append)) {
        qCritical()<<"Can't open "<<vendorPriFile.fileName()<<": "<<vendorPriFile.errorString();
        return false;
    }
    QString vendorPriHeader("include($$PWD/qompote.pri)\n");
    vendorPriHeader.append("$$setLibPath()\n");
    vendorPriHeader.append("OTHER_FILES += $$PWD/qompote.pri\n\n");
    vendorPriFile.write(vendorPriHeader.toUtf8());
    foreach (RequireInfo dependencyInfo, config_.getRequires()) {
        if (!dependencyInfo.isDownloadRequired()) {
            continue;
        }
        QString qompoterPriPath(dependencyInfo.getWorkingDirPackageName(query_)+"/qompoter.pri");
        QFile qompoterPriFile(qompoterPriPath);
        if (!qompoterPriFile.exists()) {
            qWarning()<<"\t Warning: "<<dependencyInfo.getPackageName()<<": "<<qompoterPriFile.fileName()<<" does not exist";
            continue;
        }
        if (!qompoterPriFile.open(QFile::ReadOnly)) {
            qCritical()<<"\t "<<dependencyInfo.getPackageName()<<": can't open "<<qompoterPriFile.fileName();
            continue;
        }
        vendorPriFile.write(qompoterPriFile.readAll());
        qompoterPriFile.close();
    }
    vendorPriFile.close();
    return true;
}

bool Qompoter::Qompoter::buildDependencies()
{
    bool globalResult = true;
    QFile vendorPro(query_.getVendorPath()+"vendor.pro");
    vendorPro.remove();
    foreach (RequireInfo dependency, config_.getRequires()) {
        if (!dependency.isDownloadRequired()) {
            continue;
        }
        QString packagePath(query_.getVendorPath()+dependency.getPackageName());
        QDir packageDir(packagePath);
        bool found = false;
        bool maked = false;
        qDebug()<<"\t- Compiling:"<<dependency.getPackageName()<<" ("<<dependency.getVersion()<<")";
        if (packageDir.exists()) {
            QString packageBuildName("build-"+dependency.getProjectName());
            QDir packageBuildDir(query_.getVendorPath());
            if (packageBuildDir.mkpath(packageBuildName)) {
                found = true;
                packageBuildDir.cd(packageBuildName);
                QProcess makeProcess;
                makeProcess.setWorkingDirectory(packageBuildDir.path());
                QString program;
                QStringList arguments;
                // Qmake
                program = "qmake";
                QString proFile("../"+dependency.getPackageName()+"/"+dependency.getProjectName()+".pro");
                QFile proFd(packageBuildDir.path()+"/"+proFile);
                if (!proFd.exists()) {
                    qDebug()<<"\tNo .pro file, try to generate one...";
                    if (!proFd.open(QIODevice::ReadWrite)) {
                        qCritical()<<"\tCan't open pro file: "<<proFd.fileName();
                    }
                    QString data;
                    data.append("PUBLIC_HEADERS += \\\n");
                    QStringList hFiles = packageDir.entryList(QStringList()<<"*.h"<<"*.hpp", QDir::Files);
                    foreach(QString file, hFiles) {
                        data.append("\t$$PWD/"+file+" \\\n");
                    }
                    data.append("\n");
                    data.append("HEADERS += \\\n");
                    data.append("\t$$PUBLIC_HEADERS \\\n");
                    data.append("\n");
                    data.append("SOURCES += \\\n");
                    QStringList cppFiles = packageDir.entryList(QStringList()<<"*.cpp", QDir::Files);
                    foreach(QString file, cppFiles) {
                        data.append("\t$$PWD/"+file+" \\\n");
                    }
                    data.append("\n");
                    data.append("\n\n");
                    data.append("LIBNAME = "+dependency.getProjectName()+"\n");
                    data.append("EXPORT_PATH = $$OUT_PWD/..\n");
                    data.append("EXPORT_INCLUDEPATH = $$EXPORT_PATH/include/$$LIBNAME\n");
                    data.append("EXPORT_LIBPATH = $$EXPORT_PATH/lib\n");
                    data.append("TEMPLATE = lib\n");
                    data.append("QT += core gui network script designer\n");
                    data.append("greaterThan(QT_MAJOR_VERSION, 4): QT += widgets\n");
                    data.append("CONFIG += QT\n");
                    data.append("CONFIG += staticlib\n");
                    data.append("CONFIG += debug_and_release build_all\n");
                    data.append("CONFIG(debug,debug|release) {\n");
                    data.append("\tLIBNAME = $${LIBNAME}d\n");
                    data.append("}\n");
                    data.append("TARGET = $$LIBNAME\n");
                    data.append("DESTDIR = $$EXPORT_LIBPATH\n");
                    data.append("headers.files = $$PUBLIC_HEADERS\n");
                    data.append("headers.path = $$EXPORT_INCLUDEPATH\n");
                    data.append("INSTALLS += headers\n\n");
                    proFd.write(data.toUtf8());
                    proFd.close();
                }
                arguments<<proFile;
                qDebug()<<"\tRun "<<program<<" "<<arguments;
                makeProcess.start(program, arguments);
                maked = makeProcess.waitForFinished();
                if (query_.isVerbose()) {
                    qDebug()<<"\t"<<makeProcess.readAll();
                }
                if (maked) {
                    // Make
                    program = "make";
                    arguments.clear();
                    qDebug()<<"\tRun "<<program<<arguments;
                    makeProcess.start(program, arguments);
                    maked = makeProcess.waitForFinished();
                    if (query_.isVerbose()) {
                        qDebug()<<"\t"<<makeProcess.readAll();
                    }
                    if (maked) {
                        // Make
                        program = "make";
                        arguments.clear();
                        arguments<<"install";
                        qDebug()<<"\tRun "<<program<<arguments;
                        makeProcess.start(program, arguments);
                        maked = makeProcess.waitForFinished();
                        if (query_.isVerbose()) {
                            qDebug()<<"\t"<<makeProcess.readAll();
                        }
                    }
                }
                
                // Add stuff to vendor.pro
                if (maked) {
                    QFile vendorPro(query_.getVendorPath()+"vendor.pro");
                    vendorPro.open(QIODevice::WriteOnly | QIODevice::Append);
                    QString data;
                    data.append(dependency.getProjectName()+" {\n");
                    data.append("\tLIBNAME = "+dependency.getProjectName()+"\n");
                    data.append("\tIMPORT_INCLUDEPATH = $$PWD/include/$$LIBNAME\n");
                    data.append("\tIMPORT_LIBPATH = $$PWD/lib\n");
                    data.append("\tCONFIG(debug,debug|release) {\n");
                    data.append("\t\tLIBNAME = $${LIBNAME}d\n");
                    data.append("\t}\n");
                    data.append("\tINCLUDEPATH += $$IMPORT_INCLUDEPATH\n");
                    data.append("\tLIBS += -L$$IMPORT_LIBPATH -l$${LIBNAME}\n");
                    data.append("}\n\n");
                    vendorPro.write(data.toUtf8());
                    vendorPro.close();
                }
            }
        }
        if (maked)
            qDebug()<<"\t  done";
        else if (!found)
            qCritical()<<"\t  FAILLURE: not found package";
        else
            qCritical()<<"\t  FAILLURE";
        qDebug()<<"";
        globalResult *= maked;
    }
    return globalResult;
}
