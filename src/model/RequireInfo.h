#ifndef QOMPOTER_REQUIREINFO_H
#define QOMPOTER_REQUIREINFO_H

#include <QVariantMap>

namespace Qompoter {
class RequireInfo
{
public:
    RequireInfo(QString packageName="", QString version="");
    RequireInfo(QVariantMap data);
    void fromData(QVariantMap data);
    QString toString(QString prefixe="\t");

    /**
     * @brief Full package name: vendor/project name
     * @return
     */
    const QString& packageName() const;
    void setPackageName(const QString& packageName);

    /**
     * @brief Vendor name of the package: first part of the package name
     * @return
     */
    QString vendorName() const;
    /**
     * @brief Project name of the package: last part of the package name
     * @return
     */
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

#endif // QOMPOTER_REQUIREINFO_H
