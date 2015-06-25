#ifndef QOMPOTER_IQOMPOTER_H
#define QOMPOTER_IQOMPOTER_H

#include <QObject>

namespace Qompoter {
class Query;
}

namespace Qompoter {
class IQompoter : public QObject
{
    Q_OBJECT
public:
    IQompoter(QObject *parent=0);
    virtual ~IQompoter() {}
    
    virtual bool doAction(const QString &action) = 0;
    virtual bool update() = 0;
    virtual bool install() = 0;
    virtual bool loadQompoterFile() = 0;
    
protected:
    virtual bool searchRecursiveDependencies() = 0;
    virtual bool installDependencies() = 0;
    virtual bool generateQompotePri() = 0;
    virtual bool generateVendorPri() = 0;
    virtual bool buildDependencies() = 0;
};
}

#endif // QOMPOTER_IQOMPOTER_H
