#include "HttpWrapper.h"

#include <QEventLoop>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QTimer>
#include <QUrl>
#include <QDebug>

#include "Query.h"

using namespace Qompoter;

HttpWrapper::HttpWrapper(const Query &settings, QObject *parent) :
    QObject(parent),
    wget_(settings.getWgetBin()),
    verbose_(settings.isVerbose())
{
    cd(settings.getWorkingDir());
}

bool HttpWrapper::isAvailable(const QUrl &url)
{
    QNetworkAccessManager manager;
    QNetworkRequest request(url);
    QNetworkReply *reply = manager.head(request);
    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QTimer::singleShot(2000, &loop, SLOT(quit()));
    loop.exec();
    bool res = false;
    if (!reply->isFinished()) {
        qCritical()<<"\t  Apparently can't reach the URL "<<url<<" that quickly...";
        res = false;
    }
    else {
        res = (200 == reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt());
    }
    reply->deleteLater();
    return res;
}

bool HttpWrapper::addCredentials(const QString &host, const QString &login, const QString &pwd)
{
    return false;
}

bool HttpWrapper::load(const QUrl &url, const QString &dest)
{
    QStringList args;
    args<<url.toString();
    process_.start(wget_, args);
    bool done = process_.waitForFinished();
    done *= QProcess::NormalExit == process_.exitStatus();
    outString_ = QString(process_.readAllStandardOutput());
    errorString_ = QString(process_.readAllStandardError());
    if (verbose_) {
        qDebug()<<"\t  "<<process_.program()<<" "<<args.join(" ");
        qDebug()<<"\t  "<<outString_<<errorString_;
        qDebug()<<"\t  Exit code: "<<process_.exitCode()<<" ("<<errorString_<<")";
    }
    process_.close();
    
    if (done) {
        args.clear();
        args<<"-C"<<dest+".zip";
        process_.start("unzip", args);
        bool done = process_.waitForFinished();
        done *= QProcess::NormalExit == process_.exitStatus();
        outString_ = QString(process_.readAllStandardOutput());
        errorString_ = QString(process_.readAllStandardError());
        if (verbose_) {
            qDebug()<<"\t  "<<process_.program()<<" "<<args.join(" ");
            qDebug()<<"\t  "<<outString_<<errorString_;
            qDebug()<<"\t  Exit code: "<<process_.exitCode()<<" ("<<errorString_<<")";
        }
        process_.close();
    }
    return done;
}

void HttpWrapper::cd(const QString &folder)
{
    process_.setWorkingDirectory(folder);
}

const QString &HttpWrapper::outString() const
{
    return outString_;
}

const QString &HttpWrapper::errorString() const
{
    return errorString_;
}
