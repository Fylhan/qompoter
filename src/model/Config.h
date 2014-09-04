#ifndef QOMPOTER_CONFIG_H
#define QOMPOTER_CONFIG_H

#include <QVariantMap>

#include "AuthorInfo.h"
#include "DependencyInfo.h"
#include "RepositoryInfo.h"


namespace Qompoter {
class Config
{
public:
    Config();
    Config(const Config& config);
    Config(QVariantMap data);
    void fromData(QVariantMap data);
    static Config fromFile(QString ilepath);
    QString toString(QString prefixe="");

    const QString& packageName();
    void setPackageName(const QString& packageName);

    QString vendorName();
    QString projectName();

    const QString& description();
    void setDescription(const QString& description);

    const QList<QString>& keywords();
    void setKeywords(const QList<QString>& keywords);
    void addKeyword(const QString& keyword);

    const QList<AuthorInfo>& authors();
    void setAuthors(const QList<AuthorInfo>& authors);
    void addAuthor(const AuthorInfo& author);

    const QString& license();
    void setLicense(const QString& license);

    const QString& version();
    void setVersion(const QString& version);

    const QList<DependencyInfo>& require();
    const QList<DependencyInfo>& packages();
    void setRequires(const QList<DependencyInfo>& require);
    void addPackage(const DependencyInfo& require);

    const QList<DependencyInfo>& requireDev();
    const QList<DependencyInfo>& packagesDev();
    void setRequireDevs(const QList<DependencyInfo>& requireDev);
    void addPackageDev(const DependencyInfo& requireDev);

    const QList<RepositoryInfo>& repositories();
    void setRepositories(const QList<RepositoryInfo>& repositories);
    void addRepository(const RepositoryInfo& repository);

private:
    QString packageName_;
    QString description_;
    QList<QString> keywords_;
    QList<AuthorInfo> authors_;
    QString license_;
    QString version_;
    QList<DependencyInfo> packages_;
    QList<DependencyInfo> packagesDev_;
    QList<RepositoryInfo> repositories_;
};
}

#endif // QOMPOTER_CONFIG_H
