#ifndef QOMPOTER_REQUIREINFO_H
#define QOMPOTER_REQUIREINFO_H

#include <QVariant>

#include "BuildMode.h"
#include "IncludeMode.h"

namespace Qompoter {
class RequireInfo
{
public:
    RequireInfo(QString packageName="", QString version="");
    RequireInfo(QString packageName, QVariant data);
    void fromData(QString packageName, QVariant data);
    QString toString(QString prefixe="\t");

    /**
     * @brief Full package name: vendor/project name
     * @return
     */
    const QString& getPackageName() const;
    void setPackageName(const QString& packageName);

    /**
     * @brief Vendor name of the package: first part of the package name
     * @return
     */
    QString getVendorName() const;
    /**
     * @brief Project name of the package: last part of the package name
     * @return
     */
    QString getProjectName() const;

    const QString& getVersion() const;
    void setVersion(const QString& version);

    const BuildModeEnum::BuildMode &getBuildMode() const;
    void setBuildMode(const BuildModeEnum::BuildMode &buildMode);

    const IncludeModeEnum::IncludeMode &getIncludeMode() const;
    void setIncludeMode(const IncludeModeEnum::IncludeMode &includeMode);

    const QString &getLibPath() const;
    void setLibPath(const QString& libPath);

    const bool &isDownloadRequired() const;
    void setDownloadRequired(const bool &downloadRequired);

private:
    QString packageName_;
    QString version_;
    BuildModeEnum::BuildMode buildMode_;
    IncludeModeEnum::IncludeMode includeMode_;
    QString libPath_;
    bool downloadRequired_;
};
}

#endif // QOMPOTER_REQUIREINFO_H
