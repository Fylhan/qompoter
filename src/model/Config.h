#ifndef QOMPOTER_CONFIG_H
#define QOMPOTER_CONFIG_H

#include <QVariantMap>

#include "AuthorInfo.h"
#include "PackageInfo.h"
#include "RequireInfo.h"
#include "RepositoryInfo.h"

namespace Qompoter {
class Config
{
public:
    Config();
    Config(const Config& config);
    Config(QVariantMap data);
    static Config fromFile(QString filepath, bool *ok=0);
    void fromData(QVariantMap data, bool *ok=0);
    QString toString(QString prefixe="");

    const QString& packageName() const;
    void setPackageName(const QString& packageName);

    QString vendorName() const;
    QString projectName() const;

    const QString& description() const;
    void setDescription(const QString& description);

    const QList<QString>& keywords() const;
    void setKeywords(const QList<QString>& keywords);
    void addKeyword(const QString& keyword);

    const QList<AuthorInfo>& authors() const;
    void setAuthors(const QList<AuthorInfo>& authors);
    void addAuthor(const AuthorInfo& author);

    const QString& license() const;
    void setLicense(const QString& license);

    const QString& version() const;
    void setVersion(const QString& version);

    QList<PackageInfo> packages() const;
    bool hasPackage(QString packageName, QString version="") const;
    void addPackage(const PackageInfo& package);
    void setPackages(const QHash<QString, PackageInfo>& packages);

    const QList<RequireInfo>& requires() const;
    void setRequires(const QList<RequireInfo>& requires);

    const QList<RequireInfo>& requireDev() const;
    void setRequireDevs(const QList<RequireInfo>& requireDev);
    void addRequireDev(const RequireInfo& requireDev);

    const QList<RepositoryInfo>& repositories() const;
    void setRepositories(const QList<RepositoryInfo>& repositories);
    void addRepository(const RepositoryInfo& repository);

    static QVariantMap parseFile(const QString &filepath);
    static QVariantMap parseContent(QString data);

private:
    QString packageName_;
    QString description_;
    QList<QString> keywords_;
    QList<AuthorInfo> authors_;
    QString license_;
    QString version_;
    QHash<QString, PackageInfo> packages_;
    QList<RequireInfo> requires_;
    QList<RequireInfo> requiresDev_;
    QList<RepositoryInfo> repositories_;
};
}

#endif // QOMPOTER_CONFIG_H
