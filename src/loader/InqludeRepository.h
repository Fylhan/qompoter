#ifndef QOMPOTER_INQLUDEREPOSITORY_H
#define QOMPOTER_INQLUDEREPOSITORY_H

#include "IRepository.h"
#include "GitWrapper.h"
#include "HttpWrapper.h"

namespace Qompoter {
class InqludeRepository : public IRepository
{
    Q_OBJECT
public:
    InqludeRepository(const Query &query, QObject *parent=0);
    
    bool contains(const RequireInfo &packageInfo);
    
private:
    GitWrapper git_;
    HttpWrapper http_;
    QVariantMap inqludeDb_;
};
}

#endif // QOMPOTER_INQLUDEREPOSITORY_H
