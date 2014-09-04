#include <QCoreApplication>
#include <QTextCodec>
#include <QProcess>
#include <QDir>
#include <QDebug>
#include <QCommandLineParser>

#include "ConfigFileManager.h"
#include "Config.h"
#include "Query.h"
#include "DependencyInfo.h"
#include "FsLoader.h"
#include "GitLoader.h"

using namespace Qompoter;

enum CommandLineParseResult
{
    CommandLineOk,
    CommandLineError,
    CommandLineVersionRequested,
    CommandLineHelpRequested
};

CommandLineParseResult parseCommandLine(QCommandLineParser &parser, Query &query, QString &errorMessage)
{
    parser.setApplicationDescription(QCoreApplication::applicationName());
    parser.addPositionalArgument("action", QObject::tr("Action to execute: install, update"));
    parser.setSingleDashWordOptionMode(QCommandLineParser::ParseAsLongOptions);
    const QCommandLineOption helpOption = parser.addHelpOption();
    const QCommandLineOption versionOption = parser.addVersionOption();
    QCommandLineOption verboseOption(QStringList() << "V" << "verbose", QObject::tr("Increase verbosity of messages"));
    parser.addOption(verboseOption);
    QCommandLineOption workingDirOption(QStringList() << "d" << "working-dir", QObject::tr("If specified, use the given directory as working directory"), QObject::tr("directory"));
    parser.addOption(workingDirOption);
    QCommandLineOption vendorDirOption(QStringList() << "vendor-dir", QObject::tr("If specified, use the given directory as vendor directory"), QObject::tr("directory"));
    parser.addOption(vendorDirOption);
    QCommandLineOption qompoterFileOption(QStringList() << "f" << "file", QObject::tr("If specified, use the given file as qompoter.json file"), QObject::tr("filename"));
    parser.addOption(qompoterFileOption);

    if (!parser.parse(QCoreApplication::arguments())) {
        errorMessage = parser.errorText();
        return CommandLineError;
    }
    if (parser.isSet(versionOption))
        return CommandLineVersionRequested;
    if (parser.isSet(helpOption))
        return CommandLineHelpRequested;

    if (parser.isSet(workingDirOption)) {
        query.setWorkingDir(parser.value(workingDirOption));
    }
    if (parser.isSet(vendorDirOption)) {
        query.setVendorDir(parser.value(vendorDirOption));
    }
    if (parser.isSet(qompoterFileOption)) {
        query.setQompoterFile(parser.value(qompoterFileOption));
    }
    query.setVerbose(parser.isSet(verboseOption));

    const QStringList positionalArguments = parser.positionalArguments();
    if (positionalArguments.isEmpty()) {
        errorMessage = "Argument 'action' missing.";
        return CommandLineError;
    }
    if (positionalArguments.size() > 1) {
        errorMessage = "Several 'action' arguments specified.";
        return CommandLineError;
    }
    query.setAction(positionalArguments.at(0));
    return CommandLineOk;
}



Q_DECL_EXPORT int main(int argc, char *argv[])
{
    /***************************
     * App Configuration
     ***************************/
    QCoreApplication app(argc, argv);
    QCoreApplication::setOrganizationName("Fylhan");
    QCoreApplication::setOrganizationDomain("fylhan");
    QCoreApplication::setApplicationName("Qompoter");
    QCoreApplication::setApplicationVersion("0.0.1");

    /***************************
     * Start App
     ***************************/
    QCommandLineParser parser;
    Query query;
    QString errorMessage;
    switch (parseCommandLine(parser, query, errorMessage)) {
        case CommandLineOk:
            break;
        case CommandLineError:
            fputs(qPrintable(errorMessage), stderr);
            fputs("\n\n", stderr);
            fputs(qPrintable(parser.helpText()), stderr);
            return 1;
        case CommandLineVersionRequested:
            printf("%s %s\n", qPrintable(QCoreApplication::applicationName()),
                   qPrintable(QCoreApplication::applicationVersion()));
            return 0;
        case CommandLineHelpRequested:
            parser.showHelp();
            Q_UNREACHABLE();
    }


    if (query.isVerbose()) {
        qSetMessagePattern("[%{type} | l.%{line}	| %{function}]		%{message}");
    }
    qDebug()<<"Loading qompoter repositories with package information";
    qDebug()<<"Parsing "<<query.getQompoterFile()<<"...";
    Config config = Config::fromFile(query.getWorkingDir()+query.getQompoterFile());
    if (query.isVerbose()) {
        qDebug()<<"Config:\n"<<config.toString();
    }

    QHash<QString, RepositoryInfo> repos;
    foreach(RepositoryInfo repo, config.repositories()) {
        repos.insert(repo.type(), repo);
    }
    repos.insert("fs", RepositoryInfo("git", "/media/Project/PlateformeVehiculeElectrique/4_workspace/"));
    repos.insert("git", RepositoryInfo("fs", "/media/Project/PlateformeVehiculeElectrique/4_workspace/"));

    FsLoader fsLoader(query);
    GitLoader gitLoader(query);
    bool globalResult = true;
    foreach (DependencyInfo dependency, config.packages()) {
        if (!dependency.isDownloadRequired()) {
            continue;
        }
        bool found = false;
        bool updated = false;
        qDebug()<<"\t- Installing:"<<dependency.packageName()<<" ("<<dependency.version()<<")";
        foreach(RepositoryInfo repo, repos.values()) {
            if (repo.type() == "fs" && fsLoader.isAvailable(dependency, repo)) {
                found = true;
                updated = fsLoader.load(dependency, repo);
                break;
            }
            else if (repo.type() == "git" && gitLoader.isAvailable(dependency, repo)) {
                found = true;
                updated = gitLoader.load(dependency, repo);
                break;
            }
        }
        if (updated)
            qDebug()<<"\tdone";
        else if (!found)
            qCritical()<<"\tFAILLURE: not found package";
        else
            qCritical()<<"\tFAILLURE";
        qDebug()<<"";
        globalResult *= updated;
    }
    if (!globalResult) {
        qCritical()<<"FAILLURE";
        return 1;
    }
    qDebug()<<"OK";
    return 0;
}
