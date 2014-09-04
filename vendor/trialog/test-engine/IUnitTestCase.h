#ifndef UNITTESTCASE_H
#define UNITTESTCASE_H

#include <QtCore/QString>
#include <QtTest/QtTest>
#include <QTest>

#include "AutoTestRunner.h"


class IUnitTestCase : public QObject
{
    Q_OBJECT
public:
    virtual ~IUnitTestCase() {}

private Q_SLOTS:
    virtual void initTestCase() = 0;
    virtual void cleanupTestCase() = 0;
};

#endif // UNITTESTCASE_H
