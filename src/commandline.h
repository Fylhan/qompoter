#ifndef QOMPOTER_COMMANDLINE_H
#define QOMPOTER_COMMANDLINE_H

class QCommandLineParser;
class QString;
namespace Qompoter {
class Query;
}

namespace Qompoter {
enum CommandLineParseResult
{
    CommandLineOk,
    CommandLineError,
    CommandLineVersionRequested,
    CommandLineHelpRequested
};

CommandLineParseResult parseCommandLine(QCommandLineParser &parser, Query &query, QString &errorMessage);
}

#endif // QOMPOTER_COMMANDLINE_H
