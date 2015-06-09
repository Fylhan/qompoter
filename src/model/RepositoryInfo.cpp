#include "RepositoryInfo.h"

using namespace Qompoter;

Qompoter::RepositoryInfo::RepositoryInfo(const QString &type, const QString &url, const QString &username, const QString &userpwd) :
    url_(url),
    username_(username),
    userpwd_(userpwd),
    vendorAlias_(),
    svnTrunkPath_("Trunk"),
    svnBranchesPath_("Branches"),
    svnTagsPath_("Tags")
{
    setType(type);
}

Qompoter::RepositoryInfo::RepositoryInfo(const QVariantMap &data)
{
    fromData(data);
}

void Qompoter::RepositoryInfo::fromData(const QVariantMap &data)
{
    setType(data.value("type", type_).toString());
    url_ = data.value("url", url_).toString();
    username_ = data.value("username", username_).toString();
    userpwd_ = data.value("userpwd", userpwd_).toString();
    vendorAlias_ = data.value("vendor-alias", vendorAlias_).toString();
    svnTrunkPath_ = data.value("trunk-path", svnTrunkPath_).toString();
    svnBranchesPath_ = data.value("branches-path", svnBranchesPath_).toString();
    svnTagsPath_ = data.value("tags-path", svnTagsPath_).toString();
}

QString Qompoter::RepositoryInfo::toString(const QString &prefixe) const
{
    QString str;
    str.append(prefixe+"{\n");
    str.append(prefixe+"\"type\": \""+getType()+"\",\n");
    str.append(prefixe+"\"url\": \""+getUrl()+"\",\n");
    if (!username_.isEmpty()) {
        str.append(prefixe+"\"username\": \""+getUsername()+"\",\n");
    }
    if (!userpwd_.isEmpty()) {
        str.append(prefixe+"\"userpwd\": \""+getUserpwd()+"\",\n");
    }
    if (!vendorAlias_.isEmpty()) {
        str.append(prefixe+"\"vendor-alias\": \""+vendorAlias_+"\",\n");
    }
    if (!svnTrunkPath_.isEmpty()) {
        str.append(prefixe+"\"trunk-path\": \""+svnTrunkPath_+"\",\n");
    }
    if (!svnBranchesPath_.isEmpty()) {
        str.append(prefixe+"\"branches-path\": \""+svnBranchesPath_+"\",\n");
    }
    if (!svnTagsPath_.isEmpty()) {
        str.append(prefixe+"\"tags-path\": \""+svnTagsPath_+"\",\n");
    }
    str.append(prefixe+"}\n");
    return str;
}

const QString& Qompoter::RepositoryInfo::getType() const
{
    return type_;
}

void Qompoter::RepositoryInfo::setType(const QString& type)
{
    if (0 == type.compare("vcs", Qt::CaseInsensitive)) {
        // TODO Check Github, ... when SVN will be supported
        type_ = "git";
        return;
    }
    type_ = type.toLower();
}

bool RepositoryInfo::isVcsType() const
{
    return "git" == type_ || "svn" == type_ || "hg" == type_;
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

const QString &RepositoryInfo::getVendorAlias() const
{
    return vendorAlias_;
}

void RepositoryInfo::setVendorAlias(const QString &vendorAlias)
{
    vendorAlias_ = vendorAlias;
}

const QString &RepositoryInfo::getSvnTrunkPath() const
{
    return svnTrunkPath_;
}

void RepositoryInfo::setSvnTrunkPath(const QString &svnTrunkPath)
{
    svnTrunkPath_ = svnTrunkPath;
}

const QString &RepositoryInfo::getSvnBranchesPath() const
{
    return svnBranchesPath_;
}

void RepositoryInfo::setSvnBranchesPath(const QString &svnBranchesPath)
{
    svnBranchesPath_ = svnBranchesPath;
}

const QString &RepositoryInfo::getSvnTagsPath() const
{
    return svnTagsPath_;
}

void RepositoryInfo::setSvnTagsPath(const QString &svnTagsPath)
{
    svnTagsPath_ = svnTagsPath;
}
