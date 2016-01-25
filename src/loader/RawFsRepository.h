#ifndef QOMPOTER_RAWFSREPOSITORY_H
#define QOMPOTER_RAWFSREPOSITORY_H

#include "IRepository.h"
#include "GitWrapper.h"

namespace Qompoter {
class RawFsRepository : public IRepository
{
    Q_OBJECT
public:
    RawFsRepository(const Query &query, const QString &url="", QObject *parent=0);
    
    bool contains(const RequireInfo &packageInfo);
    
private:
    GitWrapper git_;
    QString url_;
};
}

#endif // QOMPOTER_RAWFSREPOSITORY_H
