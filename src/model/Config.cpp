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
    packages_(),
    packagesDev_()
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
    this->packages_ = QList<DependencyInfo>(config.packages_);
    this->packagesDev_ = QList<DependencyInfo>(config.packagesDev_);
}
Qompoter::Config::Config(QVariantMap data) :
    packageName_(),
    description_(),
    keywords_(),
    authors_(),
    license_(),
    version_(),
    packages_(),
    packagesDev_()
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
            packages_.append(DependencyInfo(key, require.value(key).toString()));
        }
    }
    if (data.contains("requireDev")) {
        QVariantMap require = data.value("requireDev").toMap();
        foreach(QString key, require.keys()) {
            packagesDev_.append(DependencyInfo(key, require.value(key).toString()));
        }
    }
    if (data.contains("repositories")) {
        QVariantMap repositories = data.value("repositories").toMap();
        foreach(QString key, repositories.keys()) {
            repositories_.append(RepositoryInfo(key, repositories.value(key).toString()));
        }
    }
}

Config Config::fromFile(QString filepath)
{
    Config config;
    // -- Get configuration file data
    ConfigFileManager configFileManager;
    QVariantMap data = configFileManager.parseFile(filepath);
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
    foreach(DependencyInfo element, require()) {
        str.append(prefixe+element.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"requireDev:[\n");
    foreach(DependencyInfo element, requireDev()) {
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

const QString& Qompoter::Config::packageName()
{
    return packageName_;
}
void Qompoter::Config::setPackageName(const QString& name)
{
    packageName_ = name;
}

QString Qompoter::Config::projectName()
{
    if (packageName_.isEmpty() || !packageName_.contains('/')) {
        return packageName_;
    }
    return packageName_.split('/').at(1);
}

QString Qompoter::Config::vendorName()
{
    if (packageName_.isEmpty() || !packageName_.contains('/')) {
        return "";
    }
    return packageName_.split('/').at(0);
}

const QString& Qompoter::Config::description()
{
    return description_;
}
void Qompoter::Config::setDescription(const QString& description)
{
    description_ = description;
}

const QList<QString>& Qompoter::Config::keywords()
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

const QList<AuthorInfo>& Qompoter::Config::authors()
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

const QString& Qompoter::Config::license()
{
    return license_;
}
void Qompoter::Config::setLicense(const QString& license)
{
    license_ = license;
}

const QString& Qompoter::Config::version()
{
    return version_;
}
void Qompoter::Config::setVersion(const QString& version)
{
    version_ = version;
}

const QList<DependencyInfo>& Qompoter::Config::require()
{
    return packages_;
}
const QList<DependencyInfo>& Qompoter::Config::packages()
{
    return require();
}
void Qompoter::Config::setRequires(const QList<DependencyInfo>& require)
{
    packages_ = require;
}

void Config::addPackage(const DependencyInfo &require)
{
    packages_.append(require);
}

const QList<DependencyInfo>& Qompoter::Config::requireDev()
{
    return packagesDev_;
}
const QList<DependencyInfo>& Qompoter::Config::packagesDev()
{
    return requireDev();
}
void Qompoter::Config::setRequireDevs(const QList<DependencyInfo>& requireDev)
{
    packagesDev_ = requireDev;
}
void Config::addPackageDev(const DependencyInfo &requireDev)
{
    packagesDev_.append(requireDev);
}


const QList<RepositoryInfo>& Qompoter::Config::repositories()
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


