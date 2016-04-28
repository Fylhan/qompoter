#ifndef QOMPOTER_CONFIG_H
#define QOMPOTER_CONFIG_H

#include <QVariantMap>

#include "AuthorInfo.h"
#include "PackageInfo.h"
#include "RequireInfo.h"
#include "RepositoryInfo.h"
#include "TargetInfo.h"

namespace Qompoter {
class Config
{
public:
    Config();
    Config(const Config &config);
    Config(const QVariantMap &data);
    static Config fromFile(const QString &filepath, bool *ok=0);
    void fromData(const QVariantMap &data);
    QString toString(const QString &prefixe="") const;

    const QString &getPackageName() const;
    void setPackageName(const QString &getPackageName);

    QString getVendorName() const;
    QString getProjectName() const;

    const QString &getDescription() const;
    void setDescription(const QString &getDescription);

    const QList<QString> &getKeywords() const;
    void setKeywords(const QList<QString> &getKeywords);
    void addKeyword(const QString &keyword);

    const QList<AuthorInfo> &getAuthors() const;
    void setAuthors(const QList<AuthorInfo> &getAuthors);
    void addAuthor(const AuthorInfo &author);

    const QString &getLicense() const;
    void setLicense(const QString &getLicense);

    const QString &getVersion() const;
    void setVersion(const QString &getVersion);
    
    const TargetInfo &getTarget() const;
    void setTarget(const TargetInfo &target);

    const QHash<QString, PackageInfo> &getPackages() const;
    bool hasPackage(QString packageName, QString version="") const;
    void addPackage(const PackageInfo &package);
    void setPackages(const QHash<QString, PackageInfo> &packages);

    const QList<RequireInfo> &getRequires() const;
    void setRequires(const QList<RequireInfo> &getRequires);

    const QList<RequireInfo> &getRequireDev() const;
    void setRequireDevs(const QList<RequireInfo> &getRequireDev);
    void addRequireDev(const RequireInfo &getRequireDev);

    const QList<RepositoryInfo> &getRepositories() const;
    void setRepositories(const QList<RepositoryInfo> &getRepositories);
    void addRepositories(const QList<RepositoryInfo> &repository);
    void addRepository(const RepositoryInfo &repository);

    static QVariantMap parseFile(const QString &filepath);
    static QVariantMap parseContent(QString data);

private:
    QString packageName_;
    QString description_;
    QList<QString> keywords_;
    QList<AuthorInfo> authors_;
    QString license_;
    QString version_;
    TargetInfo target_;
    QHash<QString, PackageInfo> packages_;
    QList<RequireInfo> requires_;
    QList<RequireInfo> requiresDev_;
    QList<RepositoryInfo> repositories_;
};
}

#endif // QOMPOTER_CONFIG_H
