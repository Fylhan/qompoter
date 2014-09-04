#include "RepositoryInfo.h"

using namespace Qompoter;


Qompoter::RepositoryInfo::RepositoryInfo(QString type, QString url) :
    type_(type),
    url_(url)
{
}
Qompoter::RepositoryInfo::RepositoryInfo(const RepositoryInfo& parent)
{
    this->type_ = parent.type_;
    this->url_ = parent.url_;
}
Qompoter::RepositoryInfo::RepositoryInfo(QVariantMap data)
{
    fromData(data);
}
Qompoter::RepositoryInfo::~RepositoryInfo()
{
}

void Qompoter::RepositoryInfo::fromData(QVariantMap data)
{
    type_ = data.value("type", "").toString();
    url_ = data.value("url", "").toString();
}

QString Qompoter::RepositoryInfo::toString(QString prefixe)
{
    QString str;
    str.append(prefixe+"{\n");
    str.append(prefixe+"type: "+type()+"\n");
    str.append(prefixe+"url: "+url()+"\n");
    str.append(prefixe+"}");
    return str;
}

const QString& Qompoter::RepositoryInfo::type() const
{
    return type_;
}
void Qompoter::RepositoryInfo::setType(const QString& type)
{
    type_ = type;
}

const QString& Qompoter::RepositoryInfo::url() const
{
    return url_;
}
void Qompoter::RepositoryInfo::setUrl(const QString& url)
{
    url_ = url;
}
