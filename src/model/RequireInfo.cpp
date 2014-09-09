#include "RequireInfo.h"

using namespace Qompoter;

Qompoter::RequireInfo::RequireInfo(QString name, QString version) :
    _packageName(name),
    _version(version),
    _downloadRequired(true)
{
     _downloadRequired = ("qt/qt" != _packageName);
}
Qompoter::RequireInfo::RequireInfo(QVariantMap data) :
    _downloadRequired(true)
{
    fromData(data);
}

void Qompoter::RequireInfo::fromData(QVariantMap data)
{
    _packageName = data.value("name", "").toString();
    _version = data.value("version", "").toString();
    _downloadRequired = ("qt/qt" != _packageName);
}

QString Qompoter::RequireInfo::toString(QString prefixe)
{
    QString str(prefixe+"{\n");
    str.append(prefixe+"name: "+packageName()+"\n");
    str.append(prefixe+"version: "+version()+"\n");
    str.append(prefixe+"}");
    return str;
}

const QString& Qompoter::RequireInfo::packageName() const
{
    return _packageName;
}
void Qompoter::RequireInfo::setPackageName(const QString& name)
{
    _packageName = name;
}

QString Qompoter::RequireInfo::projectName() const
{
    if (_packageName.isEmpty() || !_packageName.contains('/')) {
        return _packageName;
    }
    return _packageName.split('/').at(1);
}

QString Qompoter::RequireInfo::vendorName() const
{
    if (_packageName.isEmpty() || !_packageName.contains('/')) {
        return "";
    }
    return _packageName.split('/').at(0);
}

const QString& Qompoter::RequireInfo::version() const
{
    return _version;
}
void Qompoter::RequireInfo::setVersion(const QString& version)
{
    _version = version;
}

const bool &RequireInfo::isDownloadRequired() const
{
    return _downloadRequired;
}

void RequireInfo::setDownloadRequired(const bool &downloadRequired)
{
    _downloadRequired = downloadRequired;
}
