#ifndef QOMPOTER_INQLUDELOADER_H
#define QOMPOTER_INQLUDELOADER_H

#include "ILoader.h"
#include "GitWrapper.h"
#include "HttpWrapper.h"

namespace Qompoter {
class InqludeLoader : public ILoader
{
    Q_OBJECT
public:
    InqludeLoader(const Query &query, QObject *parent=0);
    
    bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const;
    QList<RequireInfo> loadDependencies(const PackageInfo &packageInfo, bool &downloaded);
    bool load(const PackageInfo &packageInfo);
    
    
private:
    GitWrapper git_;
    HttpWrapper http_;
};
}

#endif // QOMPOTER_INQLUDELOADER_H
