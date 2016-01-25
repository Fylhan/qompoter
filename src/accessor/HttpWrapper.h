#ifndef QOMPOTER_HTTPWRAPPER_H
#define QOMPOTER_HTTPWRAPPER_H

#include <QObject>
#include <QProcess>

class QUrl;
namespace Qompoter {
class Query;
}

namespace Qompoter {
class HttpWrapper : public QObject
{
    Q_OBJECT
public:
    HttpWrapper(const Query &settings, QObject *parent=0);
    
    bool isAvailable(const QUrl &url);
    bool load(const QUrl &url, const QString &dest, bool unzip=false);
    
public slots:
    bool addCredentials(const QString &host, const QString &login, const QString &pwd);
/**
 * @defgroup Management Wget Wrapper Management
 * The Management group 
 * @{
 */
public:
    /**
     * @brief Apply the command line in the specified folder
     * @param folder Folder where to apply the command
     */
    void cd(const QString &folder);
    /**
     * @brief stdout result of the last command
     * @return stdout as string
     */
    const QString &outString() const;
    /**
     * @brief stderr result of the last command
     * @return stderr as string
     */
    const QString &errorString() const;

private:
    QProcess process_;
    QString wget_;
    bool verbose_;
    QString outString_;
    QString errorString_;
/** @} */
};
}

#endif // QOMPOTER_HTTPWRAPPER_H
