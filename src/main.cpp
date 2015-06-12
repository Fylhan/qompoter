#include <QCoreApplication>
#include <QCommandLineParser>
#include <QSettings>
#include <QDebug>

#include "Config.h"
#include "Query.h"
#include "QuerySettings.h"
#include "Qompoter.h"
#include "commandline.h"

using namespace Qompoter;

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    // App Description
    QCoreApplication app(argc, argv);
    QCoreApplication::setOrganizationName   ("qompoter");
    QCoreApplication::setOrganizationDomain ("qompoter");
    QCoreApplication::setApplicationName    ("Qompoter");
    QCoreApplication::setApplicationVersion ("0.3.0");
    
    // Persistant Settings
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, QCoreApplication::organizationName(), QCoreApplication::applicationName());
    
    // Process
    Query query;
    QuerySettings querySettings(settings, query);
    querySettings.loadSettings();
    QCommandLineParser parser;
    parser.setApplicationDescription("\nDependency manager for C++/Qt");
    QString errorMessage;
    switch (Qompoter::parseCommandLine(parser, query, errorMessage)) {
        case CommandLineOk:
            break;
        case CommandLineError:
            fputs(qPrintable(errorMessage), stderr);
            fputs("\n\n", stderr);
            fputs(qPrintable(parser.helpText()), stderr);
            return 1;
        case CommandLineVersionRequested:
            printf("%s %s%s by %s\n", qPrintable(QCoreApplication::applicationName()),
                   qPrintable(QCoreApplication::applicationVersion()),
                   qPrintable(parser.applicationDescription()),
                   qPrintable(QStringLiteral("Fylhan")));
            return 0;
        case CommandLineHelpRequested:
            parser.showHelp();
            Q_UNREACHABLE();
    }
    
    
    bool globalResult = true;
    Qompoter::Qompoter qompoter(query);
    globalResult *= qompoter.loadQompoterFile();
    if (!globalResult) {
        qCritical()<<"FAILLURE";
        return globalResult;
    }
    globalResult *= qompoter.doAction(query.getAction());
    if (!globalResult) {
        qCritical()<<"FAILLURE";
    }
    else {
        qDebug()<<"OK";
    }
    return globalResult;
}
