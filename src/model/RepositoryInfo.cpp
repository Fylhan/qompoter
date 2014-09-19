#include "RepositoryInfo.h"

using namespace Qompoter;


Qompoter::RepositoryInfo::RepositoryInfo(QString type, QString url, QString username, QString userpwd) :
    type_(type),
    url_(url),
    username_(username),
    userpwd_(userpwd)
{
}

Qompoter::RepositoryInfo::RepositoryInfo(QVariantMap data)
{
    fromData(data);
}

void Qompoter::RepositoryInfo::fromData(QVariantMap data)
{
    type_ = data.value("type", type_).toString();
    url_ = data.value("url", url_).toString();
    username_ = data.value("username", username_).toString();
    userpwd_ = data.value("userpwd", userpwd_).toString();
}

QString Qompoter::RepositoryInfo::toString(QString prefixe)
{
    QString str;
    str.append(prefixe+"{\n");
    str.append(prefixe+"type: "+getType()+"\n");
    str.append(prefixe+"url: "+getUrl()+"\n");
    if (!username_.isEmpty()) {
        str.append(prefixe+"username: "+getUsername()+"\n");
    }
    if (!userpwd_.isEmpty()) {
        str.append(prefixe+"userpwd: ********\n");
    }
    str.append(prefixe+"}");
    return str;
}

const QString& Qompoter::RepositoryInfo::getType() const
{
    return type_;
}

void Qompoter::RepositoryInfo::setType(const QString& type)
{
    type_ = type;
}

const QString& Qompoter::RepositoryInfo::getUrl() const
{
    return url_;
}

void Qompoter::RepositoryInfo::setUrl(const QString& url)
{
    url_ = url;
}

const QString &RepositoryInfo::getUsername() const
{
    return username_;
}

void RepositoryInfo::setUsername(const QString &username)
{
    username_ = username;
}

const QString &RepositoryInfo::getUserpwd() const
{
    return userpwd_;
}

void RepositoryInfo::setUserpwd(const QString &userpwd)
{
    userpwd_ = userpwd;
}
