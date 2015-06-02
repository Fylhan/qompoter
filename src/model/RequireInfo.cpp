#include "RequireInfo.h"

#include "BuildMode.h"
#include "IncludeMode.h"
#include "Query.h"

using namespace Qompoter;

Qompoter::RequireInfo::RequireInfo(const QString &name, const QString &version) :
    packageName_(name),
    version_(version),
    buildMode_(BuildModeEnum::AsItIs),
    includeMode_(IncludeModeEnum::AsItIs),
    libPath_(""),
    downloadRequired_(true)
{
    downloadRequired_ = ("qt/qt" != packageName_);
}
Qompoter::RequireInfo::RequireInfo(const QString &packageName, const QVariant &data) :
    buildMode_(BuildModeEnum::AsItIs),
    includeMode_(IncludeModeEnum::AsItIs),
    downloadRequired_(true)
{
    fromData(packageName, data);
}

void Qompoter::RequireInfo::fromData(const QString &packageName, const QVariant &data)
{
    packageName_ = packageName;
    if (data.canConvert(QVariant::Map)) {
        QVariantMap dataMap = data.toMap();
        version_ = dataMap.value("version", version_).toString();
        buildMode_ = BuildModeEnum::fromVariant(dataMap.value("build-mode", BuildModeEnum::toString(buildMode_)));
        includeMode_ = IncludeModeEnum::fromVariant(dataMap.value("include-mode", IncludeModeEnum::toString(includeMode_)));
        libPath_ = dataMap.value("lib-path", libPath_).toString();
    }
    else {
        version_ = data.toString();
    }
    downloadRequired_ = ("qt/qt" != packageName_);
}

QString Qompoter::RequireInfo::toString(const QString &prefixe)
{
    QString str(prefixe+"{\n");
    str.append(prefixe+"\"name\": \""+getPackageName()+"\",\n");
    str.append(prefixe+"\"version\": \""+getVersion()+"\",\n");
    str.append(prefixe+"\"build-mode\": \""+BuildModeEnum::toString(getBuildMode())+"\",\n");
    str.append(prefixe+"\"include-mode\": \""+IncludeModeEnum::toString(getIncludeMode())+"\",\n");
    str.append(prefixe+"\"lib-path\": \""+getLibPath()+"\",\n");
    str.append(prefixe+"},\n");
    return str;
}

QString RequireInfo::getPackagePath() const
{
    return getPackageName()+"/"+getVersion();
}

QString RequireInfo::getWorkingDirPackagePath(const Query &query) const
{
    return query.getVendorDir()+getPackageName();
}

const QString& Qompoter::RequireInfo::getPackageName() const
{
    return packageName_;
}
void Qompoter::RequireInfo::setPackageName(const QString& name)
{
    packageName_ = name;
}

QString Qompoter::RequireInfo::getProjectName() const
{
    if (packageName_.isEmpty() || !packageName_.contains('/')) {
        return packageName_;
    }
    return packageName_.split('/').at(1);
}

QString Qompoter::RequireInfo::getVendorName() const
{
    if (packageName_.isEmpty() || !packageName_.contains('/')) {
        return "";
    }
    return packageName_.split('/').at(0);
}

const QString& Qompoter::RequireInfo::getVersion() const
{
    return version_;
}
void Qompoter::RequireInfo::setVersion(const QString& version)
{
    version_ = version;
}

const BuildModeEnum::BuildMode &RequireInfo::getBuildMode() const
{
    return buildMode_;
}

void RequireInfo::setBuildMode(const BuildModeEnum::BuildMode &buildMode)
{
    buildMode_ = buildMode;
}

const IncludeModeEnum::IncludeMode &RequireInfo::getIncludeMode() const
{
    return includeMode_;
}

void RequireInfo::setIncludeMode(const IncludeModeEnum::IncludeMode &includeMode)
{
    includeMode_ = includeMode;
}

const QString &RequireInfo::getLibPath() const
{
    return libPath_;
}

void RequireInfo::setLibPath(const QString &libPath)
{
    libPath_ = libPath;
}

const bool &RequireInfo::isDownloadRequired() const
{
    return downloadRequired_;
}

void RequireInfo::setDownloadRequired(const bool &downloadRequired)
{
    downloadRequired_ = downloadRequired;
}
