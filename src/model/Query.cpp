#include "Query.h"

#include <QDir>

Qompoter::Query::Query() :
    _verbose(false),
    _qompoterFile("qompoter.json"),
    _vendorDir("vendor/")
{
}

const QString &Qompoter::Query::getAction() const
{
    return _action;
}
void Qompoter::Query::setAction(const QString &action)
{
    _action = action;
}

const bool &Qompoter::Query::isVerbose() const
{
    return _verbose;
}
void Qompoter::Query::setVerbose(const bool &verbose)
{
    _verbose = verbose;
}

const bool &Qompoter::Query::isGlobal() const
{
    return _global;
}

void Qompoter::Query::setGlobal(const bool &global)
{
    _global = global;
}

const QString &Qompoter::Query::getQompoterFile() const
{
    return _qompoterFile;
}
void Qompoter::Query::setQompoterFile(const QString &qompoterFile)
{
    _qompoterFile = qompoterFile;
}

const QString &Qompoter::Query::getWorkingDir() const
{
    return _workingDir;
}
void Qompoter::Query::setWorkingDir(const QString &workingDir)
{
    _workingDir = workingDir+("" != workingDir && !workingDir.endsWith("/") ? "/" : "");
}

const QString &Qompoter::Query::getVendorDir() const
{
    return _vendorDir;
}
void Qompoter::Query::setVendorDir(const QString &vendorDir)
{
    _vendorDir = vendorDir+("" != vendorDir && !vendorDir.endsWith("/") ? "/" : "");
    // - Check if folder exists
    if ("" != vendorDir && !QDir(vendorDir).exists()) {
        QDir().mkpath(vendorDir);
    }
}

