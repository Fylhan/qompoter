#include "commandline.h"

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QObject>
#include <QString>
#include <QStringList>

#include "Query.h"

using namespace Qompoter;

CommandLineParseResult Qompoter::parseCommandLine(QCommandLineParser &parser, Query &query, QString &errorMessage)
{
    QStringList availableActions;
    availableActions<<"install"<<"update"<<"build";
    parser.addPositionalArgument("action", QObject::tr("Action to execute: ")+availableActions.join(", "));
    parser.setSingleDashWordOptionMode(QCommandLineParser::ParseAsLongOptions);
    QCommandLineOption reposOption(QStringList() << "r" << "repo", QObject::tr("Select a repository path as a location for package discovery. E.g. gits=https://github.com."), QObject::tr("type=path"));
    parser.addOption(reposOption);
    QCommandLineOption qompoterFileOption(QStringList() << "f" << "file", QObject::tr("If specified, use the given file as qompoter.json file."), QObject::tr("filename"));
    parser.addOption(qompoterFileOption);
    QCommandLineOption workingDirOption(QStringList() << "d" << "working-dir", QObject::tr("If specified, use the given directory as working directory"), QObject::tr("directory"));
    parser.addOption(workingDirOption);
    QCommandLineOption vendorDirOption(QStringList() << "vendor-dir", QObject::tr("If specified, use the given directory as vendor directory."), QObject::tr("directory"));
    parser.addOption(vendorDirOption);
    QCommandLineOption noDevOption(QStringList()<< "no-dev", QObject::tr("Skip packages listed in require-dev."));
    parser.addOption(noDevOption);
    QCommandLineOption globalOption(QStringList() << "g" << "global", QObject::tr("Install the packages globaly on the machine instead of localy."));
    parser.addOption(globalOption);
    QCommandLineOption verboseOption(QStringList() << "V" << "verbose", QObject::tr("Increase verbosity of messages."));
    parser.addOption(verboseOption);
    const QCommandLineOption versionOption = parser.addVersionOption();
    const QCommandLineOption helpOption = parser.addHelpOption();

    if (!parser.parse(QCoreApplication::arguments())) {
        errorMessage = parser.errorText();
        return CommandLineError;
    }
    if (parser.isSet(versionOption))
        return CommandLineVersionRequested;
    if (parser.isSet(helpOption))
        return CommandLineHelpRequested;

    if (parser.isSet(reposOption)) {
        query.addRepository(parser.value(reposOption).section("=", 1), parser.value(reposOption).section("=", 0));
    }
    if (parser.isSet(qompoterFileOption)) {
        query.setQompoterFile(parser.value(qompoterFileOption));
    }
    if (parser.isSet(workingDirOption)) {
        query.setWorkingDir(parser.value(workingDirOption));
    }
    if (parser.isSet(vendorDirOption)) {
        query.setVendorDir(parser.value(vendorDirOption));
    }
    query.setDev(!parser.isSet(noDevOption));
    query.setGlobal(parser.isSet(globalOption));
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
    if (!availableActions.contains(query.getAction())) {
        errorMessage = "Unknown action \""+query.getAction()+"\". Use: "+availableActions.join(", ");
        return CommandLineError;
    }
    return CommandLineOk;
}
