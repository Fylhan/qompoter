#ifndef QOMPOTER_REQUIREINFO_H
#define QOMPOTER_REQUIREINFO_H

#include <QVariant>

#include "BuildMode.h"
#include "IncludeMode.h"
#include "PriorityMode.h"

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
     * @brief Vendor name of the package: first part of the package name
     * @return
     */
    QString getVendorName() const;
    /**
     * @brief Project name of the package: last part of the package name
     * @return
     */
    QString getProjectName() const;
    /**
     * @brief Package name: vendor/project name
     * @return
     */
    const QString &getPackageName() const;
    /**
     * @brief Package path: vendor/project name/version
     * @return
     */
    QString getPackagePath() const;
    
    /**
     * @brief Local full package path: workdir dir/vendor/project name/version
     * @return
     */
    QString getWorkingDirPackagePath(const Query &query) const;
    
    /**
     * @brief Local package name: workdir dir/vendor/project name
     * @return
     */
    QString getWorkingDirPackageName(const Query &query) const;
    
    void setPackageName(const QString &packageName);

    /**
     * @return Version number or tag/branch
     */
    const QString &getVersion() const;
    /**
     * @brief Parse the version number to dispatch the lib/src information and the real version number/tag/branch
     * @param version Raw version
     */
    void setVersion(const QString &version);
    /**
     * @return Raw version as set in the qompoter.json file
     */
    const QString &getRawVersion() const;
    /**
     * @brief Same as getVersion
     * @param version Raw version
     */
    void setRawVersion(const QString &version);
    
    /**
     * @return Define the search priority mode: lib first, lib only, src only
     */
    const PriorityModeEnum::PriorityMode &getPriorityMode() const;
    bool isLibFirst() const;
    bool isLibOnly() const;
    bool isSrcOnly() const;
    void setPriorityMode(const PriorityModeEnum::PriorityMode &priorityMode);

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
    QString rawVersion_;
    PriorityModeEnum::PriorityMode priorityMode_;
    BuildModeEnum::BuildMode buildMode_;
    IncludeModeEnum::IncludeMode includeMode_;
    QString libPath_;
    bool downloadRequired_;
};
}

#endif // QOMPOTER_REQUIREINFO_H
