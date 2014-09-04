#ifndef QOMPOTER_AUTHORINFO_H
#define QOMPOTER_AUTHORINFO_H

#include <QVariantMap>


namespace Qompoter {
class AuthorInfo
{
public:
    AuthorInfo();
    AuthorInfo(const AuthorInfo& parent);
    AuthorInfo(QVariantMap data);
    ~AuthorInfo();
    void fromData(QVariantMap data);
    QString toString(QString prefixe="\t");

    const QString& name();
    void setName(const QString& name);

    const QString& email();
    void setEmail(const QString& email);

    const QString& company();
    void setCompany(const QString& company);

    const QString& homepage();
    void setHomepage(const QString& homepage);

private:
    QString name_;
    QString email_;
    QString company_;
    QString homepage_;
};
}

#endif // QOMPOTER_AUTHORINFO_H
