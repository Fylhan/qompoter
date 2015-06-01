#ifndef QOMPOTER_QUERY_H
#define QOMPOTER_QUERY_H

#include <QString>

#include "RepositoryInfo.h"

namespace Qompoter {
class Query
{
public:
    Query();
    QString toString(const QString &prefixe="") const;

    const QString &getAction() const;
    void setAction(const QString &action);

    const bool &isVerbose() const;
    void setVerbose(const bool &verbose);

    const bool &isGlobal() const;
    void setGlobal(const bool &global);

    const bool &isDev() const;
    void setDev(const bool &dev);
    
    const int &getMaxRecurency() const;
    void setMaxRecurency(const int &maxRecurency);

    /**
     * @return qompoter file name (default qompoter.json)
     */
    const QString &getQompoterFile() const;
    void setQompoterFile(const QString &qompoterFile);

    /**
     * @brief working dir/vendor dir
     * @return 
     */
    QString getVendorPath() const;
    
    const QString &getWorkingDir() const;
    void setWorkingDir(const QString &workingDir);

    const QString &getVendorDir() const;
    void setVendorDir(const QString &vendorDir);

    const QList<RepositoryInfo> &getRepositories() const;
    void setRepositories(const QList<RepositoryInfo> &repositories);
    void setRepositories(const QStringList &repositories);
    void addRepository(const RepositoryInfo &repository);

private:
    QString action_;
    bool verbose_;
    bool dev_;
    bool global_;
    bool maxRecurency_;
    QString qompoterFile_;
    QString workingDir_;
    QString vendorDir_;
    QList<RepositoryInfo> repositories_;
};
}

#endif // QOMPOTER_QUERY_H
