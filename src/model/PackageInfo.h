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
    PackageInfo(const RequireInfo &parent, const RepositoryInfo &repository, ILoader *loader, bool alreadyDownloaded=false);

    const RepositoryInfo &repository();
    void setRepository(const RepositoryInfo &repository);

    ILoader *loader();
    void setLoader(ILoader *loader);

    const bool &isAlreadyDownloaded() const;
    void setAlreadyDownloaded(const bool &alreadyDownloaded);

private:
    ILoader *loader_;
    RepositoryInfo repository_;
    bool alreadyDownloaded_;
};
}

#endif // QOMPOTER_PACKAGEINFO_H
