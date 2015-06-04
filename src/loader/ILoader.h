#ifndef QOMPOTER_ILOADER_H
#define QOMPOTER_ILOADER_H

#include <QObject>
#include <QString>

#include "Query.h"
namespace Qompoter {
    class RequireInfo;
    class PackageInfo;
}
#include "RepositoryInfo.h"

namespace Qompoter {
class ILoader : public QObject
{
    Q_OBJECT
public:
    ILoader(const Query &query, const QString loadingType, QObject *parent=0);
    virtual ~ILoader() {}

    inline void setQuery(const Query &query) {
        query_ = query;
    }
    virtual QString getLoadingType() const;
    /**
     * @brief Is this dependency available in this repo?
     * @param packageInfo Dependency info
     * @param repositoryInfo Repository info
     * @return 
     */
    virtual bool isAvailable(const RequireInfo &packageInfo, const RepositoryInfo &repositoryInfo) const = 0;
    virtual QList<RequireInfo> loadDependencies(const PackageInfo &packageInfo, bool &downloaded) = 0;
    virtual bool load(const PackageInfo &packageInfo) const = 0;

protected:
    Query query_;
    QString loadingType_;
    
    virtual bool moveLibrary(const QString &packageDestPath) const;
};

bool rmDir(const QString &dirPath);
bool cpDir(const QString &srcPath, const QString &dstPath, bool deleteExistingDest=false);
}

#endif // QOMPOTER_ILOADER_H
