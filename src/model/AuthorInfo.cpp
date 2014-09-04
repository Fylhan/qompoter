#include "AuthorInfo.h"

using namespace Qompoter;


Qompoter::AuthorInfo::AuthorInfo() :
    name_(),
    email_(),
    company_(),
    homepage_()
{
}
Qompoter::AuthorInfo::AuthorInfo(const AuthorInfo& parent)
{
    name_ = parent.name_;
    email_ = parent.email_;
    company_ = parent.company_;
    homepage_ = parent.homepage_;
}
Qompoter::AuthorInfo::AuthorInfo(QVariantMap data)
{
    fromData(data);
}
Qompoter::AuthorInfo::~AuthorInfo()
{
}

void Qompoter::AuthorInfo::fromData(QVariantMap data)
{
    name_ = data.value("name", "").toString();
    email_ = data.value("email", "").toString();
    company_ = data.value("company", "").toString();
    homepage_ = data.value("homepage", "").toString();
}

QString Qompoter::AuthorInfo::toString(QString prefixe)
{
    QString str;
    str.append(prefixe+"{\n");
    str.append(prefixe+"name: "+name()+"\n");
    str.append(prefixe+"email: "+email()+"\n");
    str.append(prefixe+"company: "+company()+"\n");
    str.append(prefixe+"homepage: "+homepage()+"\n");
    str.append(prefixe+"}");
    return str;
}

const QString& Qompoter::AuthorInfo::name()
{
    return name_;
}
void Qompoter::AuthorInfo::setName(const QString& name)
{
    name_ = name;
}

const QString& Qompoter::AuthorInfo::email()
{
    return email_;
}
void Qompoter::AuthorInfo::setEmail(const QString& email)
{
    email_ = email;
}

const QString& Qompoter::AuthorInfo::company()
{
    return company_;
}
void Qompoter::AuthorInfo::setCompany(const QString& company)
{
    company_ = company;
}

const QString& Qompoter::AuthorInfo::homepage()
{
    return homepage_;
}
void Qompoter::AuthorInfo::setHomepage(const QString& homepage)
{
    homepage_ = homepage;
}

