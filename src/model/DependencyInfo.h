#ifndef QOMPOTER_DEPENDENCYINFO_H
#define QOMPOTER_DEPENDENCYINFO_H

#include <QVariantMap>


namespace Qompoter {
class DependencyInfo
{
public:
    DependencyInfo(QString packageName="", QString version="");
    DependencyInfo(QVariantMap data);
    void fromData(QVariantMap data);
    QString toString(QString prefixe="\t");

    const QString& packageName() const;
    void setPackageName(const QString& packageName);

    QString vendorName() const;
    QString projectName() const;

    const QString& version() const;
    void setVersion(const QString& version);

    const bool &isDownloadRequired() const;
    void setDownloadRequired(const bool &downloadRequired);

private:
    QString _packageName;
    QString _version;
    bool _downloadRequired;
};
}

#endif // QOMPOTER_DEPENDENCYINFO_H
