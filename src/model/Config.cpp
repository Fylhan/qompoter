#include "Config.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonParseError>
#include <QDebug>
#include <QRegExp>
#include <QString>

using namespace Qompoter;

Qompoter::Config::Config() 
{}

Qompoter::Config::Config(const Config &config)
{
    this->packageName_ = config.packageName_;
    this->description_ = config.description_;
    this->keywords_ = QList<QString>(config.keywords_);
    this->license_ = config.license_;
    this->version_ = config.version_;
    this->authors_ = QList<AuthorInfo>(config.authors_);
    this->target_ = TargetInfo(config.target_);
    this->requires_ = QList<RequireInfo>(config.requires_);
    this->requiresDev_ = QList<RequireInfo>(config.requiresDev_);
    this->repositories_ = QList<RepositoryInfo>(config.repositories_);
}

Qompoter::Config::Config(const QVariantMap &data)
{
    fromData(data);
}

void Qompoter::Config::fromData(const QVariantMap &data)
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
    if (data.contains("target")) {
        target_ = TargetInfo(data.value("target").toMap());
    }
    if (data.contains("require")) {
        QVariantMap require = data.value("require").toMap();
        foreach(QString key, require.keys()) {
            requires_.append(RequireInfo(key, require.value(key)));
        }
    }
    if (data.contains("require-dev")) {
        QVariantMap require = data.value("require-dev").toMap();
        foreach(QString key, require.keys()) {
            requiresDev_.append(RequireInfo(key, require.value(key)));
        }
    }
    if (data.contains("repositories")) {
        QListIterator<QVariant> it(data.value("repositories").toList());
        it.toBack();
        while (it.hasPrevious()) {
            repositories_.prepend(RepositoryInfo(it.previous().toMap()));
        }
    }
}

Config Config::fromFile(const QString &filepath, bool *ok)
{
    Config config;
    // -- Get configuration file data
    QVariantMap data = Config::parseFile(filepath);
    // Error or no data
    if (data.size() <= 0) {
        qCritical()<<"No data";
        if (0 != ok) {
            *ok = false;
        }
        return config;
    }
    
    // -- Fill new Config element
    config.fromData(data);
    if (0 != ok) {
        *ok = true;
    }
    return config;
}

QString Config::toString(const QString &prefixe) const
{
    QString str;
    str.append(prefixe+"{\n");
    str.append(prefixe+"packageName: "+getPackageName()+",\n");
    str.append(prefixe+"vendorName: "+getVendorName()+",\n");
    str.append(prefixe+"projectName: "+getProjectName()+",\n");
    str.append(prefixe+"description: "+getDescription()+",\n");
    str.append(prefixe+"keywords:[\n");
    foreach(QString element, getKeywords()) {
        str.append(prefixe+element+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"license: "+getLicense()+",\n");
    str.append(prefixe+"version: "+getVersion()+",\n");
    str.append(prefixe+"authors:[\n");
    foreach(AuthorInfo element, getAuthors()) {
        str.append(prefixe+element.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"require:[\n");
    foreach(RequireInfo element, getRequires()) {
        str.append(prefixe+element.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"requireDev:[\n");
    foreach(RequireInfo element, getRequireDev()) {
        str.append(prefixe+element.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"repositories:[\n");
    foreach(RepositoryInfo element, getRepositories()) {
        str.append(prefixe+element.toString()+",\n");
    }
    str.append(prefixe+"],\n");
    str.append(prefixe+"}");
    return str;
}

const QString &Qompoter::Config::getPackageName() const
{
    return packageName_;
}
void Qompoter::Config::setPackageName(const QString &name)
{
    packageName_ = name;
}

QString Qompoter::Config::getProjectName() const
{
    if (packageName_.isEmpty() || !packageName_.contains('/')) {
        return packageName_;
    }
    return packageName_.split('/').at(1);
}

QString Qompoter::Config::getVendorName() const
{
    if (packageName_.isEmpty() || !packageName_.contains('/')) {
        return "";
    }
    return packageName_.split('/').at(0);
}

const QString &Qompoter::Config::getDescription() const
{
    return description_;
}
void Qompoter::Config::setDescription(const QString &description)
{
    description_ = description;
}

const QList<QString> &Qompoter::Config::getKeywords() const
{
    return keywords_;
}
void Qompoter::Config::setKeywords(const QList<QString> &keywords)
{
    keywords_ = keywords;
}

void Config::addKeyword(const QString &keyword)
{
    keywords_.append(keyword);
}

const QList<AuthorInfo> &Qompoter::Config::getAuthors() const
{
    return authors_;
}
void Qompoter::Config::setAuthors(const QList<AuthorInfo> &authors)
{
    authors_ = authors;
}

void Config::addAuthor(const AuthorInfo &author)
{
    authors_.append(author);
}

const QString &Qompoter::Config::getLicense() const
{
    return license_;
}
void Qompoter::Config::setLicense(const QString &license)
{
    license_ = license;
}

const QString &Qompoter::Config::getVersion() const
{
    return version_;
}
void Qompoter::Config::setVersion(const QString &version)
{
    version_ = version;
}

const TargetInfo &Config::getTarget() const
{
    return target_;
}

void Config::setTarget(const TargetInfo &target)
{
    target_ = target;
}

const QHash<QString, PackageInfo> &Qompoter::Config::getPackages() const
{
    return packages_;
}

bool Config::hasPackage(QString packageName, QString /*version*/) const
{
    // TODO add intelligence
    return packages_.contains(packageName);
}

void Config::addPackage(const PackageInfo &package)
{
    packages_.insert(package.getPackageName(), package);
}

void Config::setPackages(const QHash<QString, PackageInfo> &packages)
{
    packages_ = packages;
}

const QList<RequireInfo> &Qompoter::Config::getRequires() const
{
    return requires_;
}
void Qompoter::Config::setRequires(const QList<RequireInfo> &require)
{
    requires_ = require;
}

const QList<RequireInfo> &Qompoter::Config::getRequireDev() const
{
    return requiresDev_;
}
void Qompoter::Config::setRequireDevs(const QList<RequireInfo> &requireDev)
{
    requiresDev_ = requireDev;
}
void Config::addRequireDev(const RequireInfo &requireDev)
{
    requiresDev_.append(requireDev);
}


const QList<RepositoryInfo> &Qompoter::Config::getRepositories() const
{
    return repositories_;
}
void Qompoter::Config::setRepositories(const QList<RepositoryInfo> &repositories)
{
    repositories_ = repositories;
}

void Config::addRepositories(const QList<RepositoryInfo> &repositories)
{
    repositories_.append(repositories);
}

void Config::addRepository(const RepositoryInfo &repository)
{
    repositories_.append(repository);
}

QVariantMap Config::parseFile(const QString &filepath)
{
    // -- Get configuration file data (JSON formated)
    QFile file(filepath);
    // - Open the file (read only)
    if (!file.open(QIODevice::ReadOnly)) {
        qCritical()<<QObject::tr("Config file not found: %1.").arg(file.errorString());
        return QVariantMap();
    }
    // - Modify file content
    // Read content
    QTextStream in(&file);
    QString data = in.readAll();
    // Close file
    file.close();
    return parseContent(data);
}

QVariantMap Config::parseContent(QString data)
{
    data = data.trimmed();
    // Remove inline comms
    QRegExp pattern = QRegExp("(^|\\[|\\{|,|\\n|\\s)//.*($|\\n)");
    pattern.setMinimal(true); //ungreedy
    data.replace(pattern, "\\1\n");
    data.replace(pattern, "\\1\n");//2 times, I am not sure why...
    // Remove bloc comms
    pattern = QRegExp("/\\*.*\\*/");
    pattern.setMinimal(true); //ungreedy
    data.replace(pattern, "");
    // Add first and last brace
    if (!data.startsWith("{") && !data.startsWith("[")) {
        data = "{\n"+data;
    }
    if (!data.endsWith("}") && !data.endsWith("]")) {
        data += "\n}";
    }
    // Remove commas before } or ]
    pattern = QRegExp(",(\\s*[}\\]])");
    pattern.setMinimal(true); //non-greedy
    data.replace(pattern, "\\1");
    
    // -- Parse JSON data
    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data.toUtf8(), &error);
    if (0 != error.error || jsonDoc.isNull() || jsonDoc.isEmpty()) {
        QString errorStr(QObject::tr("empty content"));
        if (0 != error.error) {
            errorStr = error.errorString();
        }
        qCritical()<<QObject::tr("Error when reading config file: %1.").arg(errorStr);
        return QVariantMap();
    }
    if (jsonDoc.isObject())
        return jsonDoc.object().toVariantMap();
    QVariantMap map;
    for(QJsonValue element : jsonDoc.array()) {
        QVariantMap elementMap = element.toVariant().toMap();
        map.insert(elementMap.value("name", "noname").toString()+"/"+elementMap.value("version", "*").toString(), elementMap);
    }
    return map;
}

