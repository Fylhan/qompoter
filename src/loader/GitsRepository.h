#ifndef QOMPOTER_INQLUDELOADER_H
#define QOMPOTER_INQLUDELOADER_H

#include <QString>

#include "IRepository.h"
#include "GitWrapper.h"
#include "HttpWrapper.h"
#include "PackageInfo.h"

namespace Qompoter {
class GitsRepository : public IRepository
{
    Q_OBJECT
public:
    GitsRepository(const Query &query, QObject *parent=0);
    
    bool contains(const RequireInfo &packageInfo);
//    const PackageInfo package(const RequireInfo &packageInfo);

private:
    GitWrapper git_;
    HttpWrapper http_;
};
}

#endif // QOMPOTER_INQLUDELOADER_H
