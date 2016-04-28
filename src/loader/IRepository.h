#ifndef QOMPOTER_IREPOSITORY_H
#define QOMPOTER_IREPOSITORY_H

#include <QObject>
#include <QString>

#include "PackageInfo.h"
#include "Query.h"

namespace Qompoter {
class IRepository : public QObject
{
    Q_OBJECT
public:
    IRepository(const Query &query, const QString &loadingType, QObject *parent=0);
    virtual ~IRepository() {}
    
    virtual void setQuery(const Query &query);
    virtual const QString &getLoadingType() const;
    
    /**
     * @brief Is this dependency available in this repository ?
     * @param requireInfo Dependency info
     * @return True if this repository contains this dependency
     */
    virtual bool contains(const RequireInfo &requireInfo) = 0;
    
    /**
     * @brief Package information of this dependency for this repository
     * Warning: This method will fail if the dependency does not exist in this repository!
     * @param requireInfo Dependency info
     * @return The relevant PackageInfo containing full information to load the dependency
     */
    virtual const PackageInfo package(const RequireInfo &requireInfo);
    
protected:
    Query query_;
    /**
     * @brief inqlude, raw-fs, qompotists, gits
     */
    QString loadingType_;
    /**
     * @brief package name -> package
     */
    QHash<QString, PackageInfo> packages_;
};
}

#endif // QOMPOTER_IREPOSITORY_H
