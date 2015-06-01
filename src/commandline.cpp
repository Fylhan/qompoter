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
    const QCommandLineOption helpOption = parser.addHelpOption();
    const QCommandLineOption versionOption = parser.addVersionOption();
    QCommandLineOption verboseOption(QStringList() << "V" << "verbose", QObject::tr("Increase verbosity of messages"));
    parser.addOption(verboseOption);
    QCommandLineOption globalOption(QStringList() << "g" << "global", QObject::tr("Install the dependency on the machine, instead of localy, for the current project only"));
    parser.addOption(globalOption);
    QCommandLineOption noDevOption(QStringList() << "no-dev", QObject::tr("Skip installing packages listed in require-dev"));
    parser.addOption(noDevOption);
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
    query.setDev(!parser.isSet(noDevOption));
    query.setGlobal(parser.isSet(globalOption));

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
