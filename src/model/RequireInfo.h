#ifndef QOMPOTER_REQUIREINFO_H
#define QOMPOTER_REQUIREINFO_H

#include <QVariant>

#include "BuildMode.h"
#include "IncludeMode.h"

namespace Qompoter {
class Query;
}

namespace Qompoter {
class RequireInfo
{
public:
    RequireInfo(const QString &packageName="", const QString &version="");
    RequireInfo(const QString &packageName, const QVariant &data);
    void fromData(const QString &packageName, const QVariant &data);
    QString toString(const QString &prefixe="\t");

    /**
     * @brief Package path: vendor/project name/version
     * @return
     */
    QString getPackagePath() const;
    
    /**
     * @brief Local package path: workdir dir/vendor/project name/version
     * @return
     */
    QString getWorkingDirPackagePath(const Query &query) const;
    
    /**
     * @brief Full package name: vendor/project name
     * @return
     */
    const QString &getPackageName() const;
    void setPackageName(const QString &packageName);

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

    const QString &getVersion() const;
    void setVersion(const QString &version);

    const BuildModeEnum::BuildMode &getBuildMode() const;
    void setBuildMode(const BuildModeEnum::BuildMode &buildMode);

    const IncludeModeEnum::IncludeMode &getIncludeMode() const;
    void setIncludeMode(const IncludeModeEnum::IncludeMode &includeMode);

    const QString &getLibPath() const;
    void setLibPath(const QString &libPath);

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
