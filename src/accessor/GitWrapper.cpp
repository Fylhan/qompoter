#include "GitWrapper.h"

#include <QDebug>

#include "Query.h"

using namespace Qompoter;

GitWrapper::GitWrapper(const Query &settings) :
    git_(settings.getGitBin()),
    verbose_(settings.isVerbose())
{
    cd(settings.getWorkingDir());
}

bool GitWrapper::clone(const QString &source, const QString &dest, const QString &branch)
{
    QStringList args;
    args<<source;
    if (!branch.isEmpty()) {
        args<<"-b"<<branch;
    }
    if (!dest.isEmpty()) {
        args<<dest;
    }
    return command(QStringLiteral("clone"), args);
    
}

bool GitWrapper::checkout(const QString &branch, bool force, bool createBranch)
{
    QStringList args;
    if (force) {
        args<<"-f";
    }
    if (createBranch) {
        args<<"-b";
    }
    args<<branch;
    return command(QStringLiteral("checkout"), args);
}

bool GitWrapper::reset(const QString &branch, bool hard)
{
    QStringList args;
    if (hard) {
        args<<"--hard";
    }
    args<<branch;
    return command(QStringLiteral("reset"), args);
}

QString GitWrapper::log(const int &nb, const QStringList &otherArgs)
{
    QStringList args;
    args<<"-"+QString::number(nb)<<otherArgs;
    QString outString;
    bool res = request(QStringLiteral("log"), args, outString);
    if (res) {
        return outString;
    }
    return QStringLiteral("");
}

QString GitWrapper::lastHash()
{
    return log(1, QStringList()<<"--pretty=format:\"%H\"");
}

bool GitWrapper::command(const QString &command, QStringList args)
{
    QString outString;
    return request(command, args, outString);
}

bool GitWrapper::request(const QString &command, QStringList args, QString &outString)
{
    args.prepend(command);
    gitProcess_.start(git_, args);
    bool done = gitProcess_.waitForFinished();
    done *= QProcess::NormalExit == gitProcess_.exitStatus();
    outString_ = QString(gitProcess_.readAllStandardOutput());
    errorString_ = QString(gitProcess_.readAllStandardError());
    outString = outString_;
    if (verbose_) {
        qDebug()<<"\t  "<<gitProcess_.program()<<" "<<args.join(" ");
        qDebug()<<"\t  "<<outString_<<errorString_;
        qDebug()<<"\t  Exit code: "<<gitProcess_.exitCode()<<" ("<<errorString_<<")";
    }
    gitProcess_.close();
    return done;
}

void GitWrapper::cd(const QString &folder)
{
    gitProcess_.setWorkingDirectory(folder);
}

const QString &GitWrapper::outString() const
{
    return outString_;
}

const QString &GitWrapper::errorString() const
{
    return errorString_;
}
