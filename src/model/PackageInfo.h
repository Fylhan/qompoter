#ifndef QOMPOTER_PACKAGEINFO_H
#define QOMPOTER_PACKAGEINFO_H

#include "ILoader.h"
#include "RequireInfo.h"

namespace Qompoter {
/**
 * @brief A PackageInfo is a RequireInfo with more information, it is ready to be downloaded and installed
 */
class PackageInfo : public RequireInfo
{
public:
    PackageInfo(const RequireInfo &parent, const RepositoryInfo &getRepository, ILoader *loader, bool alreadyDownloaded=false);

    const RepositoryInfo &getRepository() const;
    void setRepository(const RepositoryInfo &getRepository);

    ILoader *loader();
    void setLoader(ILoader *loader);

    /**
     * @brief Package path in the remote repository: repository/vendor/project name/version
     */
    QString getRepositoryPackagePath() const;
    /**
     * @brief Path to the qompoter.json file in the remote repository: repository/vendor/project name/version
     */
    QString getRepositoryQompoterFilePath() const;
    
    const bool &isAlreadyDownloaded() const;
    void setAlreadyDownloaded(const bool &alreadyDownloaded);

private:
    ILoader *loader_;
    RepositoryInfo repository_;
    bool alreadyDownloaded_;
};
}

#endif // QOMPOTER_PACKAGEINFO_H
