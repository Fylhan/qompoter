#ifndef QOMPOTER_REPOSITORYINFO_H
#define QOMPOTER_REPOSITORYINFO_H

#include <QVariantMap>

namespace Qompoter {
class RepositoryInfo
{
public:
    RepositoryInfo(const QString &type="", const QString &url="", const QString &username="", const QString &userpwd="");
    RepositoryInfo(const QVariantMap &data);
    void fromData(const QVariantMap &data);
    QString toString(const QString &prefixe="\t") const;
    
    /**
     * @return qompoter, inqlude, vcss, vcs, gits, git, svns, svn, hgs, hg, fs, zip, package
     */
    const QString &getType() const;
    void setType(const QString &type);
    bool isVcsType() const;
    
    const QString &getUrl() const;
    void setUrl(const QString &url);
    
    const QString &getUsername() const;
    void setUsername(const QString &username);
    
    const QString &getUserpwd() const;
    void setUserpwd(const QString &userpwd);
    
    /**
     * @brief This repository handles all packages of this vendor name
     * e.g. "inqlude" to handle all "inqlude/project name" projects
     * @return Vendor name
     */
    const QString &getVendorAlias() const;
    /**
     * @brief Change to vendor name to handle
     * @param vendorAlias Vendor name
     */
    void setVendorAlias(const QString &vendorAlias);
    
    const QString &getSvnTrunkPath() const;
    void setSvnTrunkPath(const QString &svnTrunkPath="Trunk");
    
    const QString &getSvnBranchesPath() const;
    void setSvnBranchesPath(const QString &svnBranchesPath="Branches");
    
    const QString &getSvnTagsPath() const;
    void setSvnTagsPath(const QString &svnTagsPath="Tags");
    
private:
    QString type_;
    QString url_;
    QString username_;
    QString userpwd_;
    QString vendorAlias_;
    QString svnTrunkPath_;
    QString svnBranchesPath_;
    QString svnTagsPath_;
};
}

#endif // QOMPOTER_REPOSITORYINFO_H
