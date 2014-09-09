#include "Config.h"

#include <QDebug>

#include "ConfigFileManager.h"

using namespace Qompoter;

Qompoter::Config::Config() :
    packageName_(),
    description_(),
    keywords_(),
    authors_(),
    license_(),
    version_(),
    requires_(),
    requiresDev_()
{
}

Qompoter::Config::Config(const Config& config)
{
    this->packageName_ = config.packageName_;
    this->description_ = config.description_;
    this->keywords_ = QList<QString>(config.keywords_);
    this->authors_ = QList<AuthorInfo>(config.authors_);
    this->license_ = config.license_;
    this->version_ = config.version_;
    this->requires_ = QList<RequireInfo>(config.requires_);
    this->requiresDev_ = QList<RequireInfo>(config.requiresDev_);
}

Qompoter::Config::Config(QVariantMap data) :
    packageName_(),
    description_(),
    keywords_(),
    authors_(),
    license_(),
    version_(),
    requires_(),
    requiresDev_()
{
    fromData(data);
}

void Qompoter::Config::fromData(QVariantMap data)
{
    packageName_ = data.value("name", "").toString();
    description_ = data.value("description", "").toString();
    if (data.contains("keywords")) {
        foreach(QVariant element, data.value("keywords").toList()) {
            keywords_.append(element.toString());
        }
    }
    license_ = data.value("license", "").toString();
    version_ = data.value("version", "").toString();
    if (data.contains("authors")) {
        foreach(QVariant element, data.value("authors").toList()) {
            authors_.append(AuthorInfo(element.toMap()));
        }
    }
    if (data.contains("require")) {
        QVariantMap require = data.value("require").toMap();
        foreach(QString key, require.keys()) {
            requires_.append(RequireInfo(key, require.value(key).toString()));
        }
    }
    if (data.contains("require-dev")) {
        QVariantMap require = data.value("require-dev").toMap();
        foreach(QString key, require.keys()) {
            requiresDev_.append(RequireInfo(key, require.value(key).toString()));
        }
    }
    if (data.contains("repositories")) {
        QList<QVariant> repositories = data.value("repositories").toList();
        foreach(QVariant repository, repositories) {
            QVariantMap repositoryData = repository.toMap();
            repositories_.append(RepositoryInfo(repositoryData.value("type", "").toString(), repositoryData.value("url", "").toString()));
        }
    }
}

Config Config::fromFile(QString filepath)
{
    Config config;
    // -- Get configuration file data
    QVariantMap data = ConfigFileManager::parseFile(filepath);
    // Error or no data
    if (data.size() <= 0) {
        qCritical()<<"No data";
        return config;
    }

    // -- Fill new Config element
    config.fromData(data);
    return config;
}

QString Config::toString(QString prefixe)
{
    QString str;
    str.append(prefixe+"{\n");
    str.append(prefixe+"packageName: "+packageName()+",\n");
    str.append(prefixe+"vendorName: "+vendorName()+",\n");
    str.append(prefixe+"projectName: "+projectName()+",\n");
    str.append(prefixe+"description: "+description()+",\n");
    str.append(prefixe+"keywords:[\n");
    foreach(QString element, keywords()) {
        str.append(prefixe+element+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"license: "+license()+",\n");
    str.append(prefixe+"version: "+version()+",\n");
    str.append(prefixe+"authors:[\n");
    foreach(AuthorInfo element, authors()) {
        str.append(prefixe+element.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"require:[\n");
    foreach(RequireInfo element, requires()) {
        str.append(prefixe+element.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"requireDev:[\n");
    foreach(RequireInfo element, requireDev()) {
        str.append(prefixe+element.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"repositories:[\n");
    foreach(RepositoryInfo element, repositories()) {
        str.append(prefixe+element.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"}");
    return str;
}

const QString& Qompoter::Config::packageName() const
{
    return packageName_;
}
void Qompoter::Config::setPackageName(const QString& name)
{
    packageName_ = name;
}

QString Qompoter::Config::projectName() const
{
    if (packageName_.isEmpty() || !packageName_.contains('/')) {
        return packageName_;
    }
    return packageName_.split('/').at(1);
}

QString Qompoter::Config::vendorName() const
{
    if (packageName_.isEmpty() || !packageName_.contains('/')) {
        return "";
    }
    return packageName_.split('/').at(0);
}

const QString& Qompoter::Config::description() const
{
    return description_;
}
void Qompoter::Config::setDescription(const QString& description)
{
    description_ = description;
}

const QList<QString>& Qompoter::Config::keywords() const
{
    return keywords_;
}
void Qompoter::Config::setKeywords(const QList<QString>& keywords)
{
    keywords_ = keywords;
}

void Config::addKeyword(const QString &keyword)
{
    keywords_.append(keyword);
}

const QList<AuthorInfo>& Qompoter::Config::authors() const
{
    return authors_;
}
void Qompoter::Config::setAuthors(const QList<AuthorInfo>& authors)
{
    authors_ = authors;
}

void Config::addAuthor(const AuthorInfo &author)
{
    authors_.append(author);
}

const QString& Qompoter::Config::license() const
{
    return license_;
}
void Qompoter::Config::setLicense(const QString& license)
{
    license_ = license;
}

const QString& Qompoter::Config::version() const
{
    return version_;
}
void Qompoter::Config::setVersion(const QString& version)
{
    version_ = version;
}

QList<PackageInfo> Qompoter::Config::packages() const
{
    return packages_.values();
}

bool Config::hasPackage(QString packageName, QString /*version*/) const
{
    // TODO add intelligence
    return packages_.contains(packageName);
}

void Config::addPackage(const PackageInfo &package)
{
    packages_.insert(package.packageName(), package);
}

void Config::setPackages(const QHash<QString, PackageInfo> &packages)
{
    packages_ = packages;
}

const QList<RequireInfo>& Qompoter::Config::requires() const
{
    return requires_;
}
void Qompoter::Config::setRequires(const QList<RequireInfo>& require)
{
    requires_ = require;
}

const QList<RequireInfo>& Qompoter::Config::requireDev() const
{
    return requiresDev_;
}
void Qompoter::Config::setRequireDevs(const QList<RequireInfo>& requireDev)
{
    requiresDev_ = requireDev;
}
void Config::addRequireDev(const RequireInfo &requireDev)
{
    requiresDev_.append(requireDev);
}


const QList<RepositoryInfo>& Qompoter::Config::repositories() const
{
    return repositories_;
}
void Qompoter::Config::setRepositories(const QList<RepositoryInfo>& repositories)
{
    repositories_ = repositories;
}

void Config::addRepository(const RepositoryInfo &repository)
{
    repositories_.append(repository);
}


