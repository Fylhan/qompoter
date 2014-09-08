#include "DependencyInfo.h"

using namespace Qompoter;

Qompoter::DependencyInfo::DependencyInfo(QString name, QString version) :
    _packageName(name),
    _version(version),
    _downloadRequired(true)
{
     _downloadRequired = ("qt/qt" != _packageName);
}
Qompoter::DependencyInfo::DependencyInfo(QVariantMap data) :
    _downloadRequired(true)
{
    fromData(data);
}

void Qompoter::DependencyInfo::fromData(QVariantMap data)
{
    _packageName = data.value("name", "").toString();
    _version = data.value("version", "").toString();
    _downloadRequired = ("qt/qt" != _packageName);
}

QString Qompoter::DependencyInfo::toString(QString prefixe)
{
    QString str(prefixe+"{\n");
    str.append(prefixe+"name: "+packageName()+"\n");
    str.append(prefixe+"version: "+version()+"\n");
    str.append(prefixe+"}");
    return str;
}

const QString& Qompoter::DependencyInfo::packageName() const
{
    return _packageName;
}
void Qompoter::DependencyInfo::setPackageName(const QString& name)
{
    _packageName = name;
}

QString Qompoter::DependencyInfo::projectName() const
{
    if (_packageName.isEmpty() || !_packageName.contains('/')) {
        return _packageName;
    }
    return _packageName.split('/').at(1);
}

QString Qompoter::DependencyInfo::vendorName() const
{
    if (_packageName.isEmpty() || !_packageName.contains('/')) {
        return "";
    }
    return _packageName.split('/').at(0);
}

const QString& Qompoter::DependencyInfo::version() const
{
    return _version;
}
void Qompoter::DependencyInfo::setVersion(const QString& version)
{
    _version = version;
}

const bool &DependencyInfo::isDownloadRequired() const
{
    return _downloadRequired;
}

void DependencyInfo::setDownloadRequired(const bool &downloadRequired)
{
    _downloadRequired = downloadRequired;
}
