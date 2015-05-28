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
    
    const QString &getType() const;
    void setType(const QString &type);
    
    const QString &getUrl() const;
    void setUrl(const QString &url);
    
    const QString &getUsername() const;
    void setUsername(const QString &username);
    
    const QString &getUserpwd() const;
    void setUserpwd(const QString &userpwd);
    
private:
    QString type_;
    QString url_;
    QString username_;
    QString userpwd_;
};
}

#endif // QOMPOTER_REPOSITORYINFO_H
