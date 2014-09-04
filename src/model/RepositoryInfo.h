#ifndef QOMPOTER_REPOSITORYINFO_H
#define QOMPOTER_REPOSITORYINFO_H

#include <QVariantMap>


namespace Qompoter {
class RepositoryInfo
{
public:
    RepositoryInfo(QString type="", QString url="");
    RepositoryInfo(const RepositoryInfo& parent);
    RepositoryInfo(QVariantMap data);
    ~RepositoryInfo();
    void fromData(QVariantMap data);
    QString toString(QString prefixe="\t");

    const QString& type() const;
    void setType(const QString& type);

    const QString& url() const;
    void setUrl(const QString& url);

private:
    QString type_;
    QString url_;
};
}

#endif // QOMPOTER_REPOSITORYINFO_H
