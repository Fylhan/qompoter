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
#include "PackageInfo.h"
#include "Query.h"

using namespace Qompoter;

Qompoter::Qompoter::Qompoter(Query &query, QObject *parent) :
    IQompoter(parent),
    query_(query)
{
    loaders_.insert("git", QSharedPointer<ILoader>(new GitLoader(query)));
    loaders_.insert("fs", QSharedPointer<ILoader>(new FsLoader(query)));
    loaders_.insert("http", QSharedPointer<ILoader>(new HttpLoader(query)));
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
        qDebug()<<"Update\n";
        return update();
    }
    qCritical()<<"Unknown action";
    return false;
}

bool Qompoter::Qompoter::install()
{
    bool res = true;
    if (query_.isVerbose()) {
        qDebug()<<"Search recursive dependencies...\n";
    }
    res = searchRecursiveDependencies();
    if (!res) {
        return false;
    }
    qDebug()<<"Install dependencies...\n";
    res = installDependencies();
    if (!res) {
        return false;
    }
    if (query_.isVerbose()) {
        qDebug()<<"Generate qompoter.pri\n";
    }
    generateQompoterPri();
    return true;
}

bool Qompoter::Qompoter::update()
{
    return install();
}

bool Qompoter::Qompoter::loadQompoterFile()
{
    qDebug()<<"Loading qompoter repositories with package information";
    qDebug()<<"Parsing "<<query_.getQompoterFile()<<"...";
    bool ok = false;
    config_ = Config::fromFile(query_.getWorkingDir()+query_.getQompoterFile(), &ok);
    if (query_.isVerbose()) {
        qDebug()<<"Config:\n"<<config_.toString();
    }
    config_.setRepositories(query_.getRepositories());
    return ok;
}

bool Qompoter::Qompoter::searchRecursiveDependencies()
{
    QHash<QString, PackageInfo> finalDependencyList;
    QList<RequireInfo> dependencies = config_.requires();
    if (query_.isDev()) {
        dependencies.append(config_.requireDev());
    }
    int recurency = 0;
    do {
        QList<RequireInfo> moreDepedencies;
        // Search for other dependencies in the list of dependencies
        foreach (RequireInfo dependency, dependencies) {
            if (!dependency.isDownloadRequired()) {
                continue;
            }
            qDebug()<<"";
            qDebug()<<"\t- Searching dependencies of:"<<dependency.getPackageName()<<" ("<<dependency.getVersion()<<")";
            bool found = false;
            foreach (RepositoryInfo repo, config_.repositories()) {
                if (!loaders_.contains(repo.getType())) {
                    continue;
                }
                QSharedPointer<ILoader> loader = loaders_.value(repo.getType());
                if (loader->isAvailable(dependency, repo)) {
                    found = true;
                    bool downloaded = false;
                    PackageInfo package(dependency, repo, loader.data(), downloaded);
                    moreDepedencies.append(loader->loadDependencies(package, downloaded));
                    finalDependencyList.insert(dependency.getPackageName(), package);
                    break;
                }
            }
            if (!found) {
                qCritical()<<"\t  Package not found";
            }
        }
        QMutableListIterator<RequireInfo> it(moreDepedencies);
        while (it.hasNext()) {
            if (finalDependencyList.contains(it.next().getPackageName())) {
                it.remove();
            }
        }
        dependencies = moreDepedencies;
        ++recurency;
    } while(!dependencies.isEmpty() && recurency<query_.getMaxRecurency());
    config_.setPackages(finalDependencyList);
    qDebug()<<"";
    return true;
}

bool Qompoter::Qompoter::installDependencies()
{
    bool globalResult = true;
    foreach (PackageInfo dependency, config_.packages()) {
        if (!dependency.isDownloadRequired()) {
            continue;
        }
        bool found = false;
        bool updated = false;
        qDebug()<<"\t- Installing:"<<dependency.getPackageName()<<" ("<<dependency.getVersion()<<")";
        if (0 != dependency.loader() && dependency.loader()->isAvailable(dependency, dependency.getRepository())) {
            found = true;
            updated = dependency.loader()->load(dependency);
        }
        if (updated)
            qDebug()<<"\t  done";
        else if (!found)
            qCritical()<<"\t  FAILLURE: not found package";
        else
            qCritical()<<"\t  FAILLURE";
        qDebug()<<"";
        globalResult *= updated;
    }
    return globalResult;
}

bool Qompoter::Qompoter::generateQompoterPri()
{
    QFile mainQompoterPriFile(query_.getVendorPath()+"qompoter.pri");
    mainQompoterPriFile.remove();
    if (!mainQompoterPriFile.open(QFile::ReadWrite | QFile::Append)) {
        qCritical()<<"Can't open "<<mainQompoterPriFile.fileName()<<": "<<mainQompoterPriFile.errorString();
        return false;
    }
    foreach (RequireInfo dependency, config_.packages()) {
        if (!dependency.isDownloadRequired()) {
            continue;
        }
        QString qompoterPriPath(query_.getVendorPath()+dependency.getPackageName()+"/qompoter.pri");
        QFile qompoterPriFile(qompoterPriPath);
        if (!qompoterPriFile.exists()) {
            qWarning()<<"\t Warning: "<<dependency.getPackageName()<<": "<<qompoterPriFile.fileName()<<" does not exist";
            continue;
        }
        if (!qompoterPriFile.open(QFile::ReadOnly)) {
            qCritical()<<"\t "<<dependency.getPackageName()<<": can't open "<<qompoterPriFile.fileName();
            continue;
        }
        mainQompoterPriFile.write(qompoterPriFile.readAll());
        qompoterPriFile.close();
    }
    mainQompoterPriFile.close();
    return true;
}

bool Qompoter::Qompoter::buildDependencies()
{
    bool globalResult = true;
    QFile vendorPro(query_.getVendorPath()+"vendor.pro");
    vendorPro.remove();
    foreach (RequireInfo dependency, config_.packages()) {
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
