#ifndef QOMPOTER_REPOSITORYINFO_H
#define QOMPOTER_REPOSITORYINFO_H

#include <QVariantMap>

namespace Qompoter {
class RepositoryInfo
{
public:
    RepositoryInfo(QString type="", QString url="", QString username="", QString userpwd="");
    RepositoryInfo(QVariantMap data);
    void fromData(QVariantMap data);
    QString toString(QString prefixe="\t");

    const QString& getType() const;
    void setType(const QString& type);

    const QString& getUrl() const;
    void setUrl(const QString& url);

    const QString &getUsername() const;
    void setUsername(const QString& username);

    const QString &getUserpwd() const;
    void setUserpwd(const QString& userpwd);

private:
    QString type_;
    QString url_;
    QString username_;
    QString userpwd_;
};
}

#endif // QOMPOTER_REPOSITORYINFO_H
